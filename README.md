# VPS Node Secure Proxy 🚀
One-click script to expose your Node.js app on a VPS with **HTTPS + password protection**, without needing a domain.  
It uses a **self-signed SSL certificate** so the WebCrypto API works properly in browsers.  

---

## 🔹 Features
- ✅ Auto Nginx reverse proxy  
- ✅ Self-signed HTTPS (no domain required)  
- ✅ Basic authentication (username + password)  
- ✅ Works out of the box for apps running on `localhost:3000`  

---

## 🔹 Default Login
- **Username:** `admin`  
- **Password:** `pass123`  

---

## 🔹 Usage (One Command)
Run this on your VPS:
```bash
bash <(curl -s https://raw.githubusercontent.com/askshreesen/VPS-Node-Secure-Proxy/main/selfsigned.sh)
