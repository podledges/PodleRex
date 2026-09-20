# Hardware Inventory

> **Live inventory snapshot - 2026-09-20.** This records a dated lab observation, not a standing guarantee that the link remains up or that any device remains connected or reachable.

## Control status (2026-09-20)

| Check | Result |
|-------|--------|
| Link | PC Ethernet Up, 1 Gbps |
| Reachability | RASPODLEPI-0W.local answers on IPv6 link-local |
| SSH | Works with the lab key |
| Board | Raspberry Pi Zero 2 W Rev 1.0, hostname RASPODLEPI-0W |
| Kernel | Linux 6.18.39+rpt-rpi-v7 armv7l |
| sshd | active |

## Access path

SSH used IPv6 link-local via `RASPODLEPI-0W.local` / `fe80::fe19:28ff:fe64:3e85` on the PC Ethernet interface. The Windows zone ID may be `%3`.

- User: `podledges`
- Key path: `/home/podles/.ssh/podlesp_pi_ed25519`
- The agent runtime is WSL2. SSH to the direct-Ethernet Pi uses Windows OpenSSH with the link-local address because WSL has no direct route to that NIC.
- No private key material is included here.

## Network on Pi at observation

- `lo` UP
- `eth0` UP with IPv6 only: `fe80::fe19:28ff:fe64:3e85/64` (USB Realtek LAN dongle providing the link)
- `wlan0` DOWN
- Path: direct Ethernet only (PC Realtek PCIe GbE ↔ Pi USB Ethernet)
- No IPv4 address was present on Pi `eth0`.
- Old Wi-Fi addresses `192.168.0.14` and `192.168.0.13` were dead.
- `192.168.0.10` responded to ping but was **not** this SSH Pi.

## USB devices on the Pi

1. Espressif USB JTAG/serial → `/dev/ttyACM0` (ESP32-S3 class; by-id MAC `1C:DB:D4:7A:5F:D0`)
2. CP2102 serial `0001` → `/dev/ttyUSB1` (ESP32-DEVKIT1 from prior inventory)
3. Another CP210x present; `/dev/ttyUSB0` also exists
4. Realtek USB LAN `0bda:8156` (the Ethernet dongle)
5. Terminus hub `1a40:0101`

## Serial by-id (observed)

- `usb-Espressif_USB_JTAG_serial_debug_unit_1C:DB:D4:7A:5F:D0-if00` → `ttyACM0`
- `usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0` → `ttyUSB1`

## Tool availability

`esptool` was **not** available on the Pi at observation time (`NO_ESPTOOL`).

## Authority

SSH reachability is not continuing authority to flash, reset, open serial, or change Pi configuration. Each physical operation still requires explicit one-time captain approval with identity, scope, and stop condition.
