# BMI 计算器（纯 JSP）

一个单文件 JSP 小练习：用 **JSP 基本语法**（page 指令、声明 `<%! %>`、脚本块 `<% %>`、表达式 `<%= %>`）
在服务端完成 BMI 计算与体型判定，并用内联 CSS 渲染结果。

| 项目 | 内容 |
| --- | --- |
| 应用地址 | <http://localhost:8080/dev/bmi.jsp> |
| 页面文件 | `src/main/webapp/bmi.jsp` |
| 打包名 | `bmi-web`（部署目录 `target/bmi-web`） |
| 判定标准 | 中国成人超重和肥胖症预防控制指南（WS/T 428-2013） |

>**注意:** *contextPath 由 VS Code 扩展 **Local Tomcat Launcher** 决定，本工程未建 `.vscode/settings.json`，因此使用默认值 `dev`。若配置了其它名字（如 `bmi`），上面的应用地址要同步修改。*

---

## 一、功能

1. 输入身高（cm）与体重（kg），提交后服务端计算 BMI = 体重 ÷ 身高(m)²。
2. 体型判定：**偏瘦 < 18.5 ｜ 正常 18.5~23.9 ｜ 超重 24~27.9 ｜ 肥胖 ≥ 28**。
3. 结果卡片按等级换主题色，并给出该身高下的正常体重区间与建议。
4. 用色带 + 指针直观显示 BMI 在 14~32 区间中的位置。
5. 服务端校验：身高限 50~250，体重限 3~300，非数字或留空给出中文提示，并回填已填内容。

## 二、技术要点

| 语法 | 在 `bmi.jsp` 中的体现 |
| --- | --- |
| page 指令 | `contentType` / `pageEncoding` 均为 UTF-8 |
| 声明 `<%! %>` | `calcBmi()` 计算方法、`judge()` 判定方法、`esc()` 转义方法 |
| 脚本块 `<% %>` | 取参、`setCharacterEncoding("UTF-8")`、校验分支、准备展示数据 |
| 表达式 `<%= %>` | 输出 BMI 数值、等级、建议、正常体重区间、指针位置 |
| 内置对象 | `request.getParameter()` / `getMethod()` / `setCharacterEncoding()` |
| 其他 | 表单 `POST` 回提交到自身；指针位置由服务端算出后经 `data-left` 传给内联 JS |

> 页面内不做业务计算，所有数值均在服务端算好后输出，属于「JSP 即视图 + 控制器」的写法。

## 三、目录结构

```
JSP simple fuction/
├─ pom.xml                        Maven 配置（war 打包、UTF-8、javax.servlet-api）
├─ README.md                      本文件
├─ .vscode/settings.json          （可选）Tomcat 端口与部署名
└─ src/main/webapp/
   └─ bmi.jsp                     BMI 计算器页面（本工程唯一页面）
```

`target/` 为构建产物，不纳入版本管理。

## 四、运行步骤

1. VS Code 安装扩展 **Local Tomcat Launcher**（内置 Tomcat 9，仅支持 `javax.servlet`）。
2. 确保 `mvn` 在 PATH 中（本机：`D:\Tomcat maven\apache-maven-3.9.16`）。
3. 右键 `pom.xml` → **Reload Project**，然后点状态栏 / 命令面板的 **启动 Tomcat**
   （扩展会自动执行 `mvn compile war:exploded` 并部署到 `target/bmi-web`）。
4. 浏览器打开 <http://localhost:8080/dev/bmi.jsp>。

改了 `bmi.jsp` 后扩展会热同步；若改了 `contextPath`，访问地址同步变化。

> `pom.xml` 中的 `maven-resources-plugin` 是一段**兜底**：Local Tomcat Launcher 解析
> `project.build.finalName` 失败时会把 docBase 退化成 `target\`，该插件在 `package`
> 阶段把解压后的 webapp 镜像一份到 `target\` 根目录以保证能访问。插件行为正常时可整段删除。

## 五、备注

- 本工程**没有** `src/main/webapp/WEB-INF/web.xml`，故 war-plugin 已设置 `failOnMissingWebXml=false`。