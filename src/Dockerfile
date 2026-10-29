FROM node:20-alpine

# Tạo thư mục làm việc
WORKDIR /usr/src/app

# Copy file khai báo thư viện trước để tận dụng Docker Layer Caching
COPY package*.json ./

# Chỉ cài đặt thư viện chạy thực tế (bỏ qua thư viện rác), dọn sạch bộ nhớ đệm
RUN npm install --only=production && npm cache clean --force

# Copy mã nguồn ứng dụng vào
COPY . .

# CHUẨN BẢO MẬT ENTERPRISE: Chuyển quyền sở hữu thư mục và chạy bằng non-root user
RUN chown -R node:node /usr/src/app
USER node

EXPOSE 3000

CMD ["node", "app.js"]