# 🚦 Reverse Proxy & Load Balancer Lab

Set up a small lab with **Nginx or HAProxy** as a reverse proxy & load balancer across two web servers.  
Supports **Debian/Ubuntu** and **RHEL (CentOS/Rocky/AlmaLinux)**.

![Linux](https://img.shields.io/badge/Linux-Compatible-blue) ![Bash](https://img.shields.io/badge/Shell-Bash-green) ![Nginx](https://img.shields.io/badge/Web-Nginx-lightgrey) ![HAProxy](https://img.shields.io/badge/Web-HAProxy-orange) ![Apache](https://img.shields.io/badge/Web-Apache-red)

---

## 📁 Files & Structure

```
Reverse_Proxy_LoadBalancer_Lab/
│
├─ README.md                  # Project documentation
├─ reverse_proxy_topology.png # Lab topology diagram
├─ setup_lab.sh               # Lab setup script
└─ test_lab.sh                # Lab testing script
```

---

## 🎯 Goal

Set up a **small lab environment** for practicing:

- Reverse proxy configuration (Nginx)  
- Load balancing (HAProxy)  
- Multi-server web setup  
- Lab automation via Bash scripts  

---

## 🗺️ Lab Topology

| Host   | IP Address      | Role                         |
|--------|----------------|------------------------------|
| Proxy  | 10.41.100.101  | Nginx or HAProxy             |
| Web1   | 10.41.100.247  | Apache with custom page      |
| Web2   | 10.41.100.233  | Apache with custom page      |

---

## ⚙️ Setup Instructions

1. **Clone the repository**

```bash
git clone https://github.com/gauravchile/Reverse_proxy_loadbalancer_lab.git
cd Reverse_Proxy_LoadBalancer_Lab
```

2. **Run setup script**

```bash
chmod +x setup_lab.sh
./setup_lab.sh
```

3. **Test the lab**

```bash
chmod +x test_lab.sh
./test_lab.sh
```

> 💡 Tip: Ensure all hosts are reachable and have proper firewall rules for web traffic (ports 80/443).

---

## 📝 Skills Covered

- Linux server setup (**Debian & RHEL**)  
- Apache web server configuration  
- Nginx reverse proxy setup  
- HAProxy load balancer configuration  
- Basic networking & lab topology design  

---

## 💡 Pro Tips

- You can expand the lab to **multiple web servers**.  
- Test **failover and load balancing** scenarios.  
- Use this lab as a **hands-on DevOps or Sysadmin project**.
