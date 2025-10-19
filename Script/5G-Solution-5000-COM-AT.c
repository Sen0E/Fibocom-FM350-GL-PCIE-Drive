#include <stdio.h>
#include <windows.h>
#include <setupapi.h>
#include <devguid.h>
#include <strsafe.h> 

#pragma comment(lib, "setupapi.lib")

#define READ_BUFFER_SIZE 1024
#define PORT_NAME_MAX_SIZE 32
#define FRIENDLY_NAME_MAX_SIZE 256
#define ERROR_MSG_MAX_SIZE 256
#define SERIAL_READ_TIMEOUT_MS 500

const char* TARGET_DEVICE_FRIENDLY_NAME = "5G Solution 5000 COM AT";

BOOL findPortByName(const char* targetDeviceName, char* outPortName, size_t outPortNameSize);
HANDLE connect_serial_port(const char *portName);
BOOL send_command(HANDLE hSerial, const char *command);
int read_response(HANDLE hSerial, char *buffer, int bufferSize);
void cleanup(HANDLE hSerial);

int main(int argc, char* argv[]) {
    char foundPort[PORT_NAME_MAX_SIZE];
    HANDLE hSerial = INVALID_HANDLE_VALUE;

    printf("Searching for device: '%s'...\n", TARGET_DEVICE_FRIENDLY_NAME);
    if (!findPortByName(TARGET_DEVICE_FRIENDLY_NAME, foundPort, sizeof(foundPort))) {
        fprintf(stderr, "Error: Could not find the specified device.\n");
        return 1;
    }

    printf("Found device on port: %s\n", foundPort);
    hSerial = connect_serial_port(foundPort);
    if (hSerial == INVALID_HANDLE_VALUE) {
        return 1;
    }

    if (!send_command(hSerial, "AT\r\n")) {
        cleanup(hSerial);
        return 1;
    }

    Sleep(1000);
    char buffer[READ_BUFFER_SIZE];
    int bytesRead = read_response(hSerial, buffer, sizeof(buffer));

    if (bytesRead > 0 && strstr(buffer, "OK")) {
        printf("Device connection successful. Starting monitoring loop (Press Ctrl+C to exit).\n");
        while (1) {
            send_command(hSerial, "AT+GTCAINFO?\r\n");
            Sleep(5000);
            send_command(hSerial, "AT+GTCCINFO?\r\n");
            Sleep(5000);
        }
    } else {
        fprintf(stderr, "Error: Device is not responding correctly to initial 'AT' command.\n");
        if (bytesRead > 0) {
            fprintf(stderr, "Received: %s\n", buffer);
        }
    }

    cleanup(hSerial);
    return 0;
}

void cleanup(HANDLE hSerial) {
    if (hSerial != NULL && hSerial != INVALID_HANDLE_VALUE) {
        CloseHandle(hSerial);
        printf("Serial port closed.\n");
    }
}


HANDLE connect_serial_port(const char *portName) {
    char fullPortPath[64];
    StringCchPrintfA(fullPortPath, sizeof(fullPortPath), "\\\\.\\%s", portName);

    HANDLE hComm = CreateFileA(fullPortPath,
                              GENERIC_READ | GENERIC_WRITE,
                              0,
                              NULL,
                              OPEN_EXISTING,
                              FILE_ATTRIBUTE_NORMAL,
                              NULL);

    if (hComm == INVALID_HANDLE_VALUE) {
        fprintf(stderr, "Error: Failed to open serial port %s. Code: %lu\n", portName, GetLastError());
        return INVALID_HANDLE_VALUE;
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hComm, &dcbSerialParams)) {
        fprintf(stderr, "Error: Failed to get serial port state. Code: %lu\n", GetLastError());
        CloseHandle(hComm);
        return INVALID_HANDLE_VALUE;
    }

    dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    
    if (!SetCommState(hComm, &dcbSerialParams)) {
        fprintf(stderr, "Error: Failed to set serial port parameters. Code: %lu\n", GetLastError());
        CloseHandle(hComm);
        return INVALID_HANDLE_VALUE;
    }
    
    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = SERIAL_READ_TIMEOUT_MS;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 500;
    timeouts.WriteTotalTimeoutMultiplier = 10;

    if (!SetCommTimeouts(hComm, &timeouts)) {
        fprintf(stderr, "Error: Failed to set serial port timeouts. Code: %lu\n", GetLastError());
        CloseHandle(hComm);
        return INVALID_HANDLE_VALUE;
    }

    printf("Info: Serial port %s configured successfully.\n", portName);
    return hComm;
}

BOOL send_command(HANDLE hSerial, const char *command) {
    DWORD bytesWritten;
    if (!WriteFile(hSerial, command, (DWORD)strlen(command), &bytesWritten, NULL)) {
        fprintf(stderr, "Error: Failed to write to serial port. Code: %lu\n", GetLastError());
        return FALSE;
    }
    return TRUE;
}

int read_response(HANDLE hSerial, char *buffer, int bufferSize) {
    DWORD bytesRead = 0;
    memset(buffer, 0, bufferSize);
    if (!ReadFile(hSerial, buffer, bufferSize - 1, &bytesRead, NULL)) {
        fprintf(stderr, "Error: Failed to read from serial port. Code: %lu\n", GetLastError());
        return -1;
    }
    
    return (int)bytesRead;
}

BOOL findPortByName(const char* targetDeviceName, char* outPortName, size_t outPortNameSize) {
    HDEVINFO hDevInfo;
    SP_DEVINFO_DATA deviceInfoData;
    BOOL found = FALSE;

    hDevInfo = SetupDiGetClassDevsA(&GUID_DEVCLASS_PORTS, NULL, NULL, DIGCF_PRESENT);
    if (hDevInfo == INVALID_HANDLE_VALUE) {
        fprintf(stderr, "Error in SetupDiGetClassDevsA: %lu\n", GetLastError());
        return FALSE;
    }

    deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);
    for (DWORD i = 0; SetupDiEnumDeviceInfo(hDevInfo, i, &deviceInfoData); i++) {
        char friendlyName[FRIENDLY_NAME_MAX_SIZE] = {0};
        
        if (SetupDiGetDeviceRegistryPropertyA(hDevInfo, &deviceInfoData, SPDRP_FRIENDLYNAME,
                                              NULL, (PBYTE)friendlyName, sizeof(friendlyName), NULL)) {
            
            if (strstr(friendlyName, targetDeviceName) != NULL) {
                HKEY hDeviceKey = SetupDiOpenDevRegKey(hDevInfo, &deviceInfoData, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);
                if (hDeviceKey != INVALID_HANDLE_VALUE) {
                    DWORD regPortNameSize = (DWORD)outPortNameSize;
                    if (RegQueryValueExA(hDeviceKey, "PortName", NULL, NULL, (LPBYTE)outPortName, &regPortNameSize) == ERROR_SUCCESS) {
                        found = TRUE;
                    }
                    RegCloseKey(hDeviceKey);
                }
                if (found) break;
            }
        }
    }

    SetupDiDestroyDeviceInfoList(hDevInfo);
    return found;
}