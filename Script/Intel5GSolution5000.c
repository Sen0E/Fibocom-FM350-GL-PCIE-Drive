#include <Windows.h>
#include <stdio.h>

#define MAX_PORTS 10 // 需要扫描的最大端口数
#define BUFFER_SIZE 1024

// 初始化串口
HANDLE init_serial(const char *port) {
    HANDLE hSerial = CreateFile(port, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
    if (hSerial == INVALID_HANDLE_VALUE) {
        printf("The serial port could not be opened: %s\n", port);
        return INVALID_HANDLE_VALUE;
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams)) {
        printf("Failed to get the serial port state.\n");
        CloseHandle(hSerial);
        return INVALID_HANDLE_VALUE;
    }

    dcbSerialParams.BaudRate = CBR_9600; // 9600 波特率
    dcbSerialParams.ByteSize = 8;        // 8 数据位
    dcbSerialParams.Parity   = NOPARITY; // 无奇偶校验
    dcbSerialParams.StopBits = ONESTOPBIT; // 1 停止位

    if (!SetCommState(hSerial, &dcbSerialParams)) {
        printf("Failed to set the serial port parameters.\n");
        CloseHandle(hSerial);
        return INVALID_HANDLE_VALUE;
    }

    return hSerial;
}

// 发送 AT 命令
void send_command(HANDLE hSerial, const char *command) {
    DWORD bytesWritten;
    WriteFile(hSerial, command, strlen(command), &bytesWritten, NULL);
}

// 读取串口响应
int read_response(HANDLE hSerial, char *buffer, int bufferSize) {
    DWORD bytesRead;
    if (ReadFile(hSerial, buffer, bufferSize - 1, &bytesRead, NULL)) {
        buffer[bytesRead] = '\0';
        return bytesRead;
    }
    return 0;
}

// 任务循环
void task(HANDLE hSerial) {
    char buffer[BUFFER_SIZE];
    while (1) {
        send_command(hSerial, "AT+GTSENRDTEMP=1\r\n");
        Sleep(100);
        send_command(hSerial, "AT+GTCAINFO?\r\n");
        Sleep(100);
        send_command(hSerial, "AT+GTCCINFO?\r\n");
        Sleep(1000);
    }
}

int main() {
    char portName[10];
    int found = 0;

    for (int i = 1; i <= MAX_PORTS; i++) {
        snprintf(portName, sizeof(portName), "\\\\.\\COM%d", i);
        printf("The port is being scanned: %s\n", portName);
        HANDLE hSerial = init_serial(portName);
        
        if (hSerial == INVALID_HANDLE_VALUE) {
            continue;
        }

        printf("Attempts to connect to the: %s\n", portName);
        send_command(hSerial, "AT\r\n");
        Sleep(1000);

        char buffer[BUFFER_SIZE];
        int bytesRead = read_response(hSerial, buffer, BUFFER_SIZE);
        
        if (bytesRead > 0 && strstr(buffer, "OK")) {
            printf("At device response: %s\n", buffer);
            printf("Running......\n");
            found = 1;
            task(hSerial);
        } else {
            printf("No valid response received, it may not be an AT device: %s\n", buffer);
        }

        CloseHandle(hSerial);
        printf("--------------------\n");
    }

    if (!found) {
        printf("No available serial device found.\n");
    }

    return 0;
}
