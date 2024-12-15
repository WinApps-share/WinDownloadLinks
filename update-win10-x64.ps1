# 拉取最新的 urls.json
git pull --rebase

# 加载现有的 urls.json
if (Test-Path 'urls.json') {
    try {
        $urls = Get-Content 'urls.json' | ConvertFrom-Json
        echo "Loaded existing urls.json content:"
        $urls | ConvertTo-Json -Depth 10
    } catch {
        echo "Error reading or parsing urls.json. Exiting."
        exit 1
    }
} else {
    echo "urls.json not found. Exiting."
    exit 1
}

# 执行 Fido.ps1 获取 URL，并更新对应键
try {
    $newUrl = .\Fido.ps1 -win 10 -Rel Latest -Ed Pro -locale zh-CN -lang simp -Arch x64 -geturl
    $urls.win10_x64 = $newUrl
} catch {
    echo "Error generating URL. Exiting."
    exit 1
}

# 保存更新后的 urls.json
$urls | ConvertTo-Json -Depth 10 | Out-File -FilePath 'urls.json' -Encoding utf8
echo "Updated urls.json:"
Get-Content 'urls.json'

# 提交更新
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add urls.json
git commit -m "Updated Win10_x64 URL"
git push || (echo "Push failed. Retrying..." && git pull --rebase && git push)
