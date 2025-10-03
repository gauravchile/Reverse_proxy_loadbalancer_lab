# Files & Structure
	
	Reverse_Proxy_LoadBalancer_Lab/
 		
		README.md
 		
		reverse_proxy_topology.png
 	
		setup_lab.sh

		test_lab.sh

##  Goal
Set up a small lab with **Nginx or HAProxy** as reverse proxy & load balancer across two web servers.  
Supports **Debian/Ubuntu** and **RHEL (CentOS/Rocky/Alma)**.

---

##  Lab Topology
- **Proxy (10.41.100.101)**  Nginx or HAProxy  
- **Web1 (10.41.100.247)**  Apache with custom page  
- **Web2 (10.41.100.233)**  Apache with custom page  

![Topology](topology.png)

---

##  Setup Instructions

1. Clone repo:
 
   git clone https://github.com/gauravchile/Reverse_proxy_loadbalancer_lab.git
   cd Reverse_Proxy_LoadBalancer_Lab

#  Skills Covered
	Linux server setup (Debian & RHEL)
	
	Apache web server configuration
	
	Nginx reverse proxy

	HAProxy load balancer

	Basic networking & lab topology design
