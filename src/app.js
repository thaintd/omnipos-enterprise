const express = require('express');
const os = require('os');
const app = express();
const port = process.env.WEBSITES_PORT || 3000;

// 1. Cổng giao diện chính: Hiển thị bảng điều khiển trạng thái hệ thống POS
app.get('/', (req, res) => {
  res.json({
    service: "OmniPOS Enterprise - Order & Inventory API",
    version: "1.0.0",
    active_slot_environment: process.env.ENVIRONMENT || "LOCAL",
    container_id: os.hostname(),
    private_sql_endpoint: process.env.SQL_SERVER_FQDN || "Not Configured",
    security_mode: "Zero-Trust (VNet Integrated + Managed Identity)",
    timestamp: new Date().toISOString()
  });
});

// 2. Cổng kiểm tra sức khỏe (Bắt buộc phải khớp với health_check_path = "/healthz" trong Terraform)
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: "HEALTHY", uptime_seconds: process.uptime() });
});

app.listen(port, () => {
  console.log(`OmniPOS API running on port ${port}`);
});