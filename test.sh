import subprocess

def get_service_boot_time(services):
    boot_times = {}
    for service in services:
        try:
            # Chạy lệnh systemd-analyze critical-chain
            result = subprocess.run(
                ["systemd-analyze", "critical-chain", service],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            if result.returncode == 0:
                # Phân tích kết quả đầu ra
                lines = result.stdout.splitlines()
                for line in lines:
                    if service in line and "ms" in line or "s" in line:
                        time_info = line.strip().split()[-1]
                        boot_times[service] = time_info
                        break
                else:
                    boot_times[service] = "Time not found in output"
            else:
                boot_times[service] = f"Error: {result.stderr.strip()}"
        except Exception as e:
            boot_times[service] = f"Exception occurred: {e}"
    return boot_times

# Nhập danh sách các service
services = ["nginx.service", "mysql.service", "ssh.service"]

# Lấy thời gian khởi động
boot_times = get_service_boot_time(services)

# In kết quả
for service, time in boot_times.items():
    print(f"{service}: {time}")
