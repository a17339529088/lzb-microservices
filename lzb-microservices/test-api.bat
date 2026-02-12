@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM API测试脚本 (Windows版本)
REM 使用方法: test-api.bat [服务器地址]
REM 示例: test-api.bat http://124.222.11.237:7573

if "%1"=="" (
    set BASE_URL=http://localhost:7573
) else (
    set BASE_URL=%1
)

echo ==========================================
echo LZB 微服务 API 测试
echo 服务器地址: %BASE_URL%
echo ==========================================
echo.

REM 测试1: 数据库登录
echo 【测试1】数据库登录 (grant_type=password)
echo 请求: POST %BASE_URL%/uaa/token?grant_type=password^&username=admin^&password=admin123
curl -s -X POST "%BASE_URL%/uaa/token?grant_type=password&username=admin&password=admin123" > response.json
type response.json
echo.
echo.

REM 提取token (简化版，实际需要jq或PowerShell)
echo ✅ 请手动复制上面的 accessToken 值
echo.
set /p TOKEN="请粘贴 Token: "
echo.

REM 测试2: LDAP登录
echo 【测试2】LDAP登录 (grant_type=ldap)
echo 请求: POST %BASE_URL%/uaa/token?grant_type=ldap^&username=ldap_editor_1^&password=ldap_editor_1
curl -s -X POST "%BASE_URL%/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1"
echo.
echo.

REM 测试3: 获取产品列表
echo 【测试3】获取产品列表 (需要USER角色)
echo 请求: GET %BASE_URL%/api/products
curl -s -X GET "%BASE_URL%/api/products" -H "Authorization: Bearer %TOKEN%"
echo.
echo.

REM 测试4: 创建产品
echo 【测试4】创建产品 (需要EDITOR角色)
echo 请求: POST %BASE_URL%/api/products
curl -s -X POST "%BASE_URL%/api/products" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"name\":\"测试产品\",\"description\":\"这是一个测试产品\",\"status\":\"ON_SHELF\"}"
echo.
echo.

REM 测试5: 更新产品
echo 【测试5】更新产品 (需要EDITOR角色)
echo 请求: PUT %BASE_URL%/api/products/1
curl -s -X PUT "%BASE_URL%/api/products/1" -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"name\":\"测试产品（已更新）\",\"description\":\"这是一个更新后的测试产品\",\"status\":\"ON_SHELF\"}"
echo.
echo.

REM 测试6: 再次获取产品列表
echo 【测试6】再次获取产品列表
echo 请求: GET %BASE_URL%/api/products
curl -s -X GET "%BASE_URL%/api/products" -H "Authorization: Bearer %TOKEN%"
echo.
echo.

REM 测试7: 删除产品
echo 【测试7】删除产品 (需要EDITOR角色)
echo 请求: DELETE %BASE_URL%/api/products/1
curl -s -X DELETE "%BASE_URL%/api/products/1" -H "Authorization: Bearer %TOKEN%"
echo.
echo.

REM 测试8: 验证删除
echo 【测试8】验证产品已删除
echo 请求: GET %BASE_URL%/api/products
curl -s -X GET "%BASE_URL%/api/products" -H "Authorization: Bearer %TOKEN%"
echo.
echo.

echo ==========================================
echo 测试完成！
echo ==========================================

del response.json 2>nul
pause
