---
name: go-format
description: "运行标准的 Go 验证流程（goimports 格式化 + 测试）。当用户请求格式化 + 测试，或 Go 代码提交前验证时使用此技能。"
---

# Go 格式化与测试

当用户希望为 Go 代码执行精确的两步验证工作流时，使用此技能。

## 工作流程

1. 确保 goimports 已安装。
   - 命令：`go install golang.org/x/tools/cmd/goimports@latest`
   - 可执行文件路径：`$(go env GOPATH)/bin/goimports`

2. 读取项目模块名。
   - 命令：`awk '/^module / {print $2}' go.mod`
   - 输出示例：`github.com/user/project` 或 `project-name`

3. 运行格式化（第一步）。
   - 命令：`$(go env GOPATH)/bin/goimports -w -local <module-name> .`
   - `<module-name>` 替换为第二步读取的模块名
   - `-local` 参数确保项目包 import 排在最后，顺序为：标准库 → 第三方库 → 项目包

4. 运行测试（第二步）。
   - 命令：`go test ./...`
   
5. 为用户总结结果。
   - `goimports` 是否成功。
   - 测试是否通过。
   - 如果测试失败，包含失败的包名和首要的错误信息行。

## 报告格式

- `第一步 (goimports)`：成功/失败，以及是否有文件被修改。
- `第二步 (go test ./...)`：成功/失败，以及关键的包级结果。
- `总体`：通过/失败，以及失败时的后续操作建议。

## 注意事项

- 不要使用破坏性的 git 命令。
- 不要 Suppress 失败；直接报告命令的失败结果。
- 保持报告简洁且可操作。
