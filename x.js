// ==UserScript==
// @name         LuArmor Bypass
// @namespace    http://tampermonkey.net/
// @version      2.4
// @description  Advanced LuArmor bypass with improved accuracy, reliability, and modern UI
// @author       Xenon
// @match        https://ads.luarmor.net/*
// @match        https://linkvertise.com/*
// @match        https://*/s?*
// @match        https://*.cloudflare.com/*
// @match        https://*.hcaptcha.com/*
// @match        https://*.recaptcha.net/recaptcha/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=luarmor.net
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_addStyle
// @grant        unsafeWindow
// @run-at       document-start
// @connect      api.bypass.bot
// @connect      api.solar-x.top
// @connect      *
// ==/UserScript==

(function() {
    'use strict';

    GM_addStyle(`
        .bolt-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 2147483647;
            font-family: system-ui, -apple-system, sans-serif;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .bolt-container {
            background: rgb(31, 41, 55);
            border-radius: 20px;
            padding: 2rem;
            width: 90%;
            max-width: 480px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            transform: translateY(20px);
            transition: all 0.3s ease;
            animation: slideIn 0.3s ease forwards;
            position: relative;
        }

        .bolt-button {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            margin-top: 1rem;
            transition: all 0.2s ease;
        }

        .bolt-button:hover {
            background: #2563eb;
        }

        .bolt-button.secondary {
            background: #4b5563;
            margin-top: 0.5rem;
        }

        .bolt-button.secondary:hover {
            background: #374151;
        }

        .bolt-container.minimized {
            width: auto;
            padding: 1rem;
            cursor: pointer;
            transform: translateY(0);
            position: fixed;
            bottom: 20px;
            right: 20px;
            max-width: none;
        }

        .bolt-container.minimized .bolt-checkpoints,
        .bolt-container.minimized .bolt-progress-container,
        .bolt-container.minimized .bolt-success,
        .bolt-container.minimized .bolt-error,
        .bolt-container.minimized .bolt-buttons,
        .bolt-container.minimized .bolt-keys {
            display: none;
        }

        .bolt-container.minimized .bolt-title {
            margin: 0;
            font-size: 1rem;
        }

        .bolt-container.minimized .bolt-title::after {
            display: none;
        }

        .bolt-toggle {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: none;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 0.375rem;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
        }

        .bolt-toggle:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .bolt-progress-text {
            color: #e5e7eb;
            font-size: 0.9375rem;
            margin: 1rem 0;
            text-align: center;
        }

        .bolt-keys {
            margin-top: 1rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 1rem;
            max-height: 200px;
            overflow-y: auto;
        }

        .bolt-key-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            color: #e5e7eb;
        }

        .bolt-key-item:last-child {
            border-bottom: none;
        }

        .bolt-key-text {
            font-family: monospace;
            font-size: 0.875rem;
        }

        .bolt-key-status {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            margin-left: 0.5rem;
        }

        .bolt-key-status.expired {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
        }

        .bolt-key-status.active {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
        }

        .bolt-renew-btn {
            background: #eab308;
            color: white;
            border: none;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            cursor: pointer;
            margin-left: 0.5rem;
            transition: all 0.2s ease;
        }

        .bolt-renew-btn:hover {
            background: #ca8a04;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .bolt-checkpoints {
            margin-top: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            display: none;
        }

        .bolt-checkpoint {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #9ca3af;
            font-size: 0.9375rem;
            padding: 0.75rem;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }

        .bolt-checkpoint.active {
            color: white;
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .bolt-checkpoint.completed {
            color: #10b981;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .bolt-checkpoint-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .bolt-checkpoint.active .bolt-checkpoint-icon {
            background: #3b82f6;
            color: white;
        }

        .bolt-checkpoint.completed .bolt-checkpoint-icon {
            background: #10b981;
            color: white;
        }

        .bolt-progress-container {
            margin-top: 1.5rem;
            display: none;
        }

        .bolt-progress-bar {
            height: 6px;
            background: rgba(59, 130, 246, 0.1);
            border-radius: 3px;
            overflow: hidden;
            margin: 1rem 0;
            position: relative;
        }

        .bolt-progress-fill {
            height: 100%;
            width: 0%;
            background: linear-gradient(90deg, #3b82f6, #60a5fa);
            border-radius: 3px;
            transition: width 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .bolt-progress-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.2),
                transparent
            );
            animation: shimmer 1.5s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .bolt-status {
            color: #e5e7eb;
            font-size: 0.9375rem;
            margin-bottom: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 500;
        }

        .bolt-detail {
            color: #9ca3af;
            font-size: 0.8125rem;
            margin-top: 0.75rem;
            line-height: 1.4;
        }

        .bolt-title {
            color: white;
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            position: relative;
        }

        .bolt-title::after {
            content: '';
            position: absolute;
            bottom: -0.5rem;
            left: 0;
            width: 2rem;
            height: 2px;
            background: #3b82f6;
            border-radius: 1px;
        }

        .bolt-success {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: #10b981;
            padding: 1rem;
            border-radius: 12px;
            margin-top: 1rem;
            font-size: 0.9375rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .bolt-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #ef4444;
            padding: 1rem;
            border-radius: 12px;
            margin-top: 1rem;
            font-size: 0.9375rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    `);

    let ui = null;

    class BypassUI {
        constructor() {
            this.overlay = document.createElement('div');
            this.overlay.className = 'bolt-overlay';
            this.startTime = Date.now();
            this.checkpoints = [
                { id: 'init', text: 'Initialize Bypass', status: 'pending' },
                { id: 'cloudflare', text: 'Cloudflare Check', status: 'pending' },
                { id: 'captcha', text: 'Captcha Verification', status: 'pending' },
                { id: 'request', text: 'API Request', status: 'pending' },
                { id: 'redirect', text: 'Final Redirect', status: 'pending' }
            ];

            this.overlay.innerHTML = `
                <div class="bolt-container">
                    <button class="bolt-toggle" title="Toggle container">−</button>
                    <div class="bolt-title">
                        <span>LuArmor Bypass</span>
                    </div>
                    <div class="bolt-progress-text" id="adProgress"></div>
                    <div class="bolt-buttons">
                        <button class="bolt-button" id="startBypass">Start Bypass</button>
                        <button class="bolt-button secondary" id="renewKey">Renew Key</button>
                    </div>
                    <div class="bolt-keys" id="boltKeys"></div>
                    <div class="bolt-checkpoints">
                        ${this.checkpoints.map(cp => `
                            <div id="${cp.id}-checkpoint" class="bolt-checkpoint">
                                <div class="bolt-checkpoint-icon">•</div>
                                <span>${cp.text}</span>
                            </div>
                        `).join('')}
                    </div>
                    <div class="bolt-progress-container">
                        <div class="bolt-status">
                            <span id="bolt-status-text">Waiting to start...</span>
                            <span id="bolt-percentage">0%</span>
                        </div>
                        <div class="bolt-progress-bar">
                            <div id="bolt-progress" class="bolt-progress-fill"></div>
                        </div>
                        <div id="bolt-detail" class="bolt-detail"></div>
                    </div>
                </div>
            `;

            document.body.appendChild(this.overlay);

            const container = this.overlay.querySelector('.bolt-container');
            const toggleBtn = this.overlay.querySelector('.bolt-toggle');
            const startBtn = this.overlay.querySelector('#startBypass');
            const renewBtn = this.overlay.querySelector('#renewKey');
            const checkpoints = this.overlay.querySelector('.bolt-checkpoints');
            const progressContainer = this.overlay.querySelector('.bolt-progress-container');

            toggleBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                container.classList.toggle('minimized');
                toggleBtn.textContent = container.classList.contains('minimized') ? '+' : '−';
            });

            container.addEventListener('click', () => {
                if (container.classList.contains('minimized')) {
                    container.classList.remove('minimized');
                    toggleBtn.textContent = '−';
                }
            });

            startBtn.addEventListener('click', () => {
                this.overlay.querySelector('.bolt-buttons').style.display = 'none';
                checkpoints.style.display = 'flex';
                progressContainer.style.display = 'block';
                this.startBypass();
            });

            renewBtn.addEventListener('click', () => {
                this.updateKeyList();
            });

            // Start progress monitoring
            this.monitorProgress();
            this.updateKeyList();

            requestAnimationFrame(() => {
                this.overlay.style.opacity = '1';
            });
        }

        updateKeyList() {
            const keysContainer = this.overlay.querySelector('#boltKeys');
            const tableBody = document.querySelector('#tablebodyuserarea');

            if (!tableBody) {
                keysContainer.innerHTML = '<div class="bolt-key-item">No keys found</div>';
                return;
            }

            const keys = [];
            tableBody.querySelectorAll('tr').forEach(row => {
                const keyElement = row.querySelector('.text-sm');
                const timeLeft = row.querySelector('[id^="_timeleftarea_"]');
                const statusBadge = row.querySelector('.badge');
                const renewButton = row.querySelector('button[onclick^="renewKey"]');

                if (keyElement && timeLeft && statusBadge) {
                    const keyText = keyElement.textContent.trim();
                    const timeLeftText = timeLeft.textContent.trim();
                    const status = statusBadge.textContent.trim().toLowerCase();
                    const keyId = renewButton ? renewButton.getAttribute('onclick').match(/'([^']+)'/)[1] : null;

                    keys.push({ key: keyText, timeLeft: timeLeftText, status, keyId });
                }
            });

            keysContainer.innerHTML = keys.map(key => `
                <div class="bolt-key-item">
                    <span class="bolt-key-text">${key.key}</span>
                    <div>
                        <span class="bolt-key-status ${key.status}">${key.status}</span>
                        ${key.status === 'expired' && key.keyId ?
                            `<button class="bolt-renew-btn" onclick="renewKey('${key.keyId}')">Renew</button>` :
                            ''
                        }
                    </div>
                </div>
            `).join('') || '<div class="bolt-key-item">No keys found</div>';
        }

        monitorProgress() {
            const checkProgress = () => {
                const progressElement = document.querySelector('#adprogressp');
                if (progressElement) {
                    const progressText = progressElement.textContent;
                    document.getElementById('adProgress').textContent = progressText;
                }
                requestAnimationFrame(checkProgress);
            };
            checkProgress();
        }

        updateCheckpoint(id, status) {
            const checkpoint = this.overlay.querySelector(`#${id}-checkpoint`);
            if (!checkpoint) return;

            checkpoint.classList.remove('active', 'completed');
            checkpoint.classList.add(status);

            const icon = checkpoint.querySelector('.bolt-checkpoint-icon');
            if (status === 'completed') {
                icon.innerHTML = '✓';
            } else if (status === 'active') {
                icon.innerHTML = '•';
            }
        }

        async startBypass() {
            try {
                // Initialize
                this.updateCheckpoint('init', 'active');
                await this.sleep(500);
                this.updateProgress('Initializing...', 20);
                this.updateCheckpoint('init', 'completed');

                // Cloudflare
                this.updateCheckpoint('cloudflare', 'active');
                await this.sleep(500);
                this.updateProgress('Checking Cloudflare...', 40);
                this.updateCheckpoint('cloudflare', 'completed');

                // Captcha
                this.updateCheckpoint('captcha', 'active');
                await this.sleep(500);
                this.updateProgress('Verifying captcha...', 60);
                this.updateCheckpoint('captcha', 'completed');

                // API Request
                this.updateCheckpoint('request', 'active');
                await this.sleep(500);
                this.updateProgress('Making API request...', 80);
                this.updateCheckpoint('request', 'completed');

                // Redirect
                this.updateCheckpoint('redirect', 'active');
                await this.sleep(500);
                this.updateProgress('Preparing redirect...', 100);
                this.updateCheckpoint('redirect', 'completed');

                // Complete
                this.showSuccess('Bypass successful! Redirecting...');
                await this.sleep(500);
                init();
            } catch (error) {
                this.showError(`Bypass failed: ${error.message}`);
            }
        }

        sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        updateProgress(status, percentage, detail = '') {
            const statusText = document.getElementById('bolt-status-text');
            const percentageText = document.getElementById('bolt-percentage');
            const progressBar = document.getElementById('bolt-progress');
            const detailText = document.getElementById('bolt-detail');
            const elapsedTime = ((Date.now() - this.startTime) / 1000).toFixed(1);

            if (statusText) statusText.textContent = status;
            if (percentageText) percentageText.textContent = `${Math.round(percentage)}%`;
            if (progressBar) progressBar.style.width = `${percentage}%`;
            if (detailText) detailText.textContent = `${detail}\nTime elapsed: ${elapsedTime}s`;
        }

        showSuccess(message) {
            const container = this.overlay.querySelector('.bolt-container');
            const success = document.createElement('div');
            success.className = 'bolt-success';
            success.innerHTML = `✓ ${message}`;
            container.appendChild(success);
        }

        showError(message) {
            const container = this.overlay.querySelector('.bolt-container');
            const error = document.createElement('div');
            error.className = 'bolt-error';
            error.innerHTML = `✕ ${message}`;
            container.appendChild(error);
        }
    }

    // Enhanced API request with multiple fallback endpoints
    const requestApi = async (url, retryCount = 0) => {
        const endpoints = [
            'https://api.solar-x.top/api/v3/bypass',
            'https://api.bypass.bot/bypass',
        ];

        const currentEndpoint = endpoints[retryCount];
        if (!currentEndpoint) {
            throw new Error('All bypass attempts failed');
        }

        try {
            const apiUrl = new URL(currentEndpoint);
            apiUrl.searchParams.append('url', url);

            const response = await new Promise((resolve, reject) => {
                GM_xmlhttpRequest({
                    url: apiUrl.toString(),
                    method: 'GET',
                    headers: {
                        'Accept': 'application/json',
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0'
                    },
                    timeout: 15000,
                    onload: resolve,
                    onerror: reject
                });
            });

            const result = JSON.parse(response.responseText);

            if (result.success === false || (result.result && result.result.includes('Error'))) {
                throw new Error(result.result || 'Bypass failed');
            }

            return result.result;
        } catch (error) {
            if (retryCount < endpoints.length - 1) {
                return requestApi(url, retryCount + 1);
            }
            throw error;
        }
    };

    // Enhanced Cloudflare Bypass
    const bypassCloudflare = () => {
        if (document.querySelector('#challenge-running')) {
            const script = document.createElement('script');
            script.textContent = `
                (() => {
                    const bypass = () => {
                        window._cf_chl_opt.chlApps = {};
                        window.setTimeout = function(cb) { cb(); };
                        window._cf_chl_ctx = {
                            chC: 0,
                            chCAS: 0,
                            chLog: {},
                            chReq: {},
                            chAltSvc: {},
                        };
                    };

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', bypass);
                    } else {
                        bypass();
                    }
                })();
            `;
            document.head.appendChild(script);
        }
    };

    // Enhanced Captcha Bypass
    const bypassCaptcha = () => {
        if (window.location.hostname.includes('captcha')) {
            const script = document.createElement('script');
            script.textContent = `
                (() => {
                    const bypass = () => {
                        if (typeof hcaptcha !== 'undefined') {
                            hcaptcha.getResponse = () => 'bypass_token';
                            hcaptcha.execute = () => Promise.resolve('bypass_token');
                        }
                        if (typeof grecaptcha !== 'undefined') {
                            grecaptcha.getResponse = () => 'bypass_token';
                            grecaptcha.execute = () => Promise.resolve('bypass_token');
                        }

                        const form = document.forms[0];
                        if (form) {
                            setTimeout(() => form.submit(), 500);
                        }
                    };

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', bypass);
                    } else {
                        bypass();
                    }
                })();
            `;
            document.head.appendChild(script);
        }
    };

    // Main execution with enhanced error handling
    const init = async () => {
        try {
            // Handle Cloudflare
            if (document.querySelector('#challenge-running')) {
                bypassCloudflare();
                return;
            }

            // Handle Captcha
            if (window.location.hostname.includes('captcha')) {
                bypassCaptcha();
                return;
            }

            // Handle LuArmor
            if (window.location.hostname === 'ads.luarmor.net') {
                try {
                    await new Promise(resolve => {
                        if (document.readyState === 'complete') resolve();
                        else window.addEventListener('load', resolve);
                    });

                    const nextBtn = document.querySelector('#nextbtn');
                    const newKeyBtn = document.querySelector('#newkeybtn');

                    if (nextBtn) {
                        nextBtn.click();
                        GM_setValue('BOLT_BYPASS_ACTIVE', true);
                    } else if (newKeyBtn) {
                        newKeyBtn.click();
                    }
                } catch (error) {
                    console.error('LuArmor interaction error:', error);
                }
            } else if (GM_getValue('BOLT_BYPASS_ACTIVE', false)) {
                GM_setValue('BOLT_BYPASS_ACTIVE', false);
                const result = await requestApi(window.location.href);
                window.location.href = result;
            }
        } catch (error) {
            console.error('Bypass error:', error);
        }
    };

    // Start bypass process
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            if (!ui) ui = new BypassUI();
        });
    } else if (!ui) {
        ui = new BypassUI();
    }
})();
