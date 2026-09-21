<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Locale" %>
<%!
    /** 计算 BMI：体重(kg) / 身高(m)² */
    private double calcBmi(double heightCm, double weightKg) {
        double heightM = heightCm / 100.0;
        return weightKg / (heightM * heightM);
    }

    /** 依据中国成人标准 WS/T 428-2013 判定体型，结果依次为 {等级, 说明, 卡片主题类名} */
    private String[] judge(double bmi) {
        if (bmi < 18.5) {
            return new String[]{"偏瘦", "体重低于正常范围，建议适当增加营养摄入。", "card-thin"};
        } else if (bmi < 24.0) {
            return new String[]{"正常", "体重处于健康范围，请继续保持。", "card-normal"};
        } else if (bmi < 28.0) {
            return new String[]{"超重", "体重略高于健康范围，建议控制饮食并增加运动。", "card-over"};
        } else {
            return new String[]{"肥胖", "体重明显高于健康范围，建议咨询医生制定减重方案。", "card-obese"};
        }
    }

    /** 简单转义，避免回显内容破坏页面结构 */
    private String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String heightStr = request.getParameter("height");
    String weightStr = request.getParameter("weight");

    boolean submitted = "POST".equalsIgnoreCase(request.getMethod())
            && heightStr != null && weightStr != null;

    String error = null;        // 校验失败时的提示
    double heightCm = 0, weightKg = 0, bmi = 0;
    String[] result = null;     // {等级, 说明, 卡片主题类名}

    if (submitted) {
        heightStr = heightStr.trim();
        weightStr = weightStr.trim();

        if (heightStr.isEmpty() || weightStr.isEmpty()) {
            error = "身高和体重都不能为空，请填写后再计算。";
        } else {
            try {
                heightCm = Double.parseDouble(heightStr);
                weightKg = Double.parseDouble(weightStr);

                if (heightCm < 50 || heightCm > 250) {
                    error = "身高请输入 50 ~ 250 之间的厘米数。";
                } else if (weightKg < 3 || weightKg > 300) {
                    error = "体重请输入 3 ~ 300 之间的千克数。";
                } else {
                    bmi = calcBmi(heightCm, weightKg);
                    result = judge(bmi);
                }
            } catch (NumberFormatException e) {
                error = "身高和体重必须是数字，例如 170 和 60.5。";
            }
        }
    }

    // 结果指针在色带上的位置（把 BMI 14~32 映射到 0%~100%）
    double markerPercent = 0;
    String markerLeft = "0%";   // 服务端先拼好百分比，页面里就不用把表达式塞进样式
    if (result != null) {
        markerPercent = (bmi - 14.0) / (32.0 - 14.0) * 100.0;
        markerPercent = Math.max(0, Math.min(100, markerPercent));
        markerLeft = String.format(Locale.US, "%.2f", markerPercent) + "%";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BMI 计算器</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #eef2ff 0%, #e6fffa 100%);
            color: #1f2937;
        }
        .card {
            width: 100%;
            max-width: 460px;
            background: #fff;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 18px 45px rgba(15, 23, 42, .12);
        }
        h1 {
            margin: 0 0 6px;
            font-size: 24px;
            letter-spacing: .5px;
        }
        .subtitle {
            margin: 0 0 24px;
            font-size: 13px;
            color: #6b7280;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 14px;
            font-weight: 600;
        }
        .field { margin-bottom: 18px; }
        .input-wrap { position: relative; }
        input[type="text"] {
            width: 100%;
            padding: 12px 52px 12px 14px;
            font-size: 16px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }
        input[type="text"]:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, .15);
        }
        .unit {
            position: absolute;
            top: 50%;
            right: 14px;
            transform: translateY(-50%);
            font-size: 13px;
            color: #9ca3af;
        }
        .buttons { display: flex; gap: 12px; margin-top: 24px; }
        button {
            flex: 1;
            padding: 12px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 10px;
            border: 1px solid transparent;
            cursor: pointer;
            transition: transform .12s, box-shadow .2s, background .2s;
        }
        button:active { transform: translateY(1px); }
        .btn-primary {
            color: #fff;
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            box-shadow: 0 8px 18px rgba(79, 70, 229, .28);
        }
        .btn-primary:hover { box-shadow: 0 10px 22px rgba(79, 70, 229, .34); }
        .btn-reset { background: #f3f4f6; color: #374151; }
        .btn-reset:hover { background: #e5e7eb; }
        .alert {
            margin-top: 22px;
            padding: 12px 14px;
            font-size: 14px;
            border-radius: 10px;
            background: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }
        .result { margin-top: 26px; }
        .result-card {
            border-radius: 14px;
            padding: 18px 20px;
            color: #fff;
        }
        /* 结果卡片主题色：服务端只输出等级类名，颜色统一写在样式表里 */
        .card-thin   { background: #3b82f6; }
        .card-normal { background: #16a34a; }
        .card-over   { background: #f59e0b; }
        .card-obese  { background: #dc2626; }
        .result-value {
            display: flex;
            align-items: baseline;
            gap: 10px;
        }
        .bmi-number { font-size: 40px; font-weight: 700; line-height: 1; }
        .bmi-label { font-size: 14px; opacity: .9; }
        .level {
            margin-top: 10px;
            font-size: 15px;
            font-weight: 600;
        }
        .advice { margin-top: 6px; font-size: 13px; line-height: 1.6; opacity: .95; }
        .scale { margin-top: 16px; }
        .scale-track { position: relative; height: 20px; }
        /* 色带分界按真实阈值绘制：18.5 / 24 / 28 在 14~32 区间上的位置 */
        .scale-bar {
            position: absolute;
            left: 0;
            right: 0;
            top: 5px;
            height: 10px;
            border-radius: 999px;
            background: linear-gradient(90deg,
                #93c5fd 0 25%,
                #86efac 25% 55.56%,
                #fcd34d 55.56% 77.78%,
                #fca5a5 77.78% 100%);
        }
        .marker {
            position: absolute;
            top: 0;
            width: 4px;
            height: 20px;
            border-radius: 3px;
            background: #111827;
            box-shadow: 0 0 0 2px #fff;
            transform: translateX(-50%);
        }
        .scale-labels {
            position: relative;
            height: 15px;
            margin-top: 4px;
            font-size: 11px;
            color: #6b7280;
        }
        .scale-labels span {
            position: absolute;
            transform: translateX(-50%);
        }
        .legend {
            margin-top: 2px;
            font-size: 11px;
            text-align: center;
            color: #6b7280;
        }
        .footnote {
            margin-top: 22px;
            font-size: 12px;
            line-height: 1.7;
            color: #9ca3af;
        }
    </style>
</head>
<body>
<div class="card">
    <h1>BMI 计算器</h1>
    <p class="subtitle">BMI = 体重(kg) ÷ 身高(m)²</p>

    <form method="post" action="bmi.jsp">
        <div class="field">
            <label for="height">身高</label>
            <div class="input-wrap">
                <input type="text" id="height" name="height" value="<%= esc(heightStr) %>"
                       placeholder="例如 170" autocomplete="off">
                <span class="unit">cm</span>
            </div>
        </div>

        <div class="field">
            <label for="weight">体重</label>
            <div class="input-wrap">
                <input type="text" id="weight" name="weight" value="<%= esc(weightStr) %>"
                       placeholder="例如 60.5" autocomplete="off">
                <span class="unit">kg</span>
            </div>
        </div>

        <div class="buttons">
            <button type="submit" class="btn-primary">开始计算</button>
            <button type="reset" class="btn-reset">重置</button>
        </div>
    </form>

    <% if (error != null) { %>
    <div class="alert"><%= esc(error) %></div>
    <% } %>

    <% if (result != null) { %>
    <div class="result">
        <div class="result-card <%= result[2] %>">
            <div class="result-value">
                <span class="bmi-number"><%= String.format(Locale.US, "%.1f", bmi) %></span>
                <span class="bmi-label">BMI 指数</span>
            </div>
            <div class="level">体型判定：<%= result[0] %></div>
            <div class="advice">
                身高 <%= String.format(Locale.US, "%.1f", heightCm) %> cm，体重 <%= String.format(Locale.US, "%.1f", weightKg) %> kg，
                该身高下的正常体重区间约为
                <%= String.format(Locale.US, "%.1f", 18.5 * Math.pow(heightCm / 100.0, 2)) %> ~
                <%= String.format(Locale.US, "%.1f", 23.9 * Math.pow(heightCm / 100.0, 2)) %> kg。
            </div>
            <div class="advice"><%= result[1] %></div>
        </div>

        <div class="scale">
            <div class="scale-track">
                <div class="scale-bar"></div>
                <div class="marker" data-left="<%= markerLeft %>"></div>
            </div>
            <div class="scale-labels">
                <span style="left: 25%;">18.5</span>
                <span style="left: 55.56%;">24</span>
                <span style="left: 77.78%;">28</span>
            </div>
            <div class="legend">偏瘦 &lt;18.5 ｜ 正常 18.5~23.9 ｜ 超重 24~27.9 ｜ 肥胖 ≥28</div>
        </div>

        <script>
            // 指针位置由服务端通过 data-left 传下来，这里再写到样式上
            (function () {
                var marker = document.querySelector(".marker");
                if (marker) {
                    marker.style.left = marker.getAttribute("data-left");
                }
            })();
        </script>
    </div>
    <% } %>

    <p class="footnote">
        判定标准：中国成人超重和肥胖症预防控制指南（WS/T 428-2013）。<br>
        结果仅供日常参考，不能替代专业医疗建议。
    </p>
</div>
</body>
</html>
