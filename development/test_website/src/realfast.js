'use strict';

// Production Environment Configuration
// TODO: Replace these values with your Salesforce org's configuration
const AGENT_ID = '[SALESFORCE_AGENT_ID]';
const AGENT_NAME = '[AGENT_NAME]';
const AGENT_URL = '[SALESFORCE_EMBEDDED_MESSAGING_URL]';

// Simple chat prompt message
const CHAT_MESSAGE = {
  text: 'Hi, I am Emma, your digital AI assistant.',
  delay: 500
};

// Track events using Clarity if available
function trackEvent(eventName) {
  if (window.clarity) {
    window.clarity('event', eventName);
  }
}

// Create and inject CSS styles
function injectStyles() {
  const style = document.createElement('style');
  style.textContent = `
    .floating-message-container {
      position: fixed;
      bottom: 100px;
      right: 20px;
      width: auto;
      font-family: Arial, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 10px;
      z-index: 999999;
    }

    .floating-message {
      max-width: 360px;
      padding: 15px 20px;
      border-radius: 18px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      animation: fadeIn 0.5s ease-out;
      position: relative;
      background: white;
      color: #333;
      transition: all 0.3s ease;
      cursor: pointer;
    }

    .clickable {
      border-radius: 100px;
      color: #3277e6;
    }

    .floating-message:hover {
      opacity: 0.9;
    }

    .floating-chat-icon {
      position: fixed;
      bottom: 20px;
      right: 20px;
      width: 60px;
      height: 60px;
      background: #28323c;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
      cursor: pointer;
      z-index: 10000;
    }

    .floating-chat-icon svg {
      width: 30px;
      height: 30px;
      fill: white;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .close-prompt-messages-btn {
      position: relative;
      background: #f9fafbAA;
      border: none;
      outline: none;
      border-radius: 25px;
      height: 32px;
      width: 32px;
      cursor: pointer;
      color: #555;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  `;
  document.head.appendChild(style);
}

// Hide message prompts
function hideMessages() {
  const container = document.querySelector('.floating-message-container');
  if (container) {
    container.style.display = 'none';
  }
}

// Open chat and hide message prompts
function openChat() {
  const chatButton = document.querySelector(
    '#embeddedMessagingConversationButton'
  );
  if (chatButton) {
    chatButton.click();
    hideMessages();
  } else {
    console.error('Chat button not found.');
  }
}

// Display message prompts
function showMessages() {
  // Create container
  const container = document.createElement('div');
  container.className = 'floating-message-container';
  document.body.appendChild(container);

  // Create close button
  const closeButton = document.createElement('button');
  closeButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12z"/></svg>';
  closeButton.className = 'close-prompt-messages-btn';
  closeButton.onclick = (e) => {
    e.preventDefault();
    e.stopPropagation();
    hideMessages();
    trackEvent('Clicked_Close_Chat');
  };
  container.appendChild(closeButton);

  // Create message prompt
  setTimeout(() => {
    const messageElement = document.createElement('div');
    messageElement.className = 'floating-message';
    messageElement.textContent = CHAT_MESSAGE.text;
    messageElement.addEventListener('click', () => {
      trackEvent('Clicked_Chat_Prompt');
      openChat();
    });
    container.appendChild(messageElement);
  }, CHAT_MESSAGE.delay);
}

// Initialize message prompts with retry logic
function initMessagePrompts(attempts = 10) {
  const chatButton = document.querySelector('#embeddedMessagingConversationButton');

  if (chatButton) {
    showMessages();
    chatButton.addEventListener('click', function () {
      hideMessages();
      trackEvent('Clicked_Open_Chat');
    });
    console.log('Chat prompts initialized successfully.');
  } else if (attempts > 0) {
    setTimeout(() => initMessagePrompts(attempts - 1), 1000);
  } else {
    console.error('Failed to initialize chat prompts after multiple attempts.');
  }
}

// Initialize embedded messaging service
// eslint-disable-next-line no-unused-vars -- Called from HTML onload attribute
function initEmbeddedMessaging() {
  try {
    embeddedservice_bootstrap.settings.language = 'en_US';

    // Handle ready event
    window.addEventListener('onEmbeddedMessagingReady', () => {
      console.log('Embedded messaging ready');
    });

    // Initialize the embedded service
    embeddedservice_bootstrap.init(AGENT_ID, AGENT_NAME, AGENT_URL, {
      scrt2URL: '[SALESFORCE_SCRT2_URL]'
    });

    // Check if widget was previously opened
    const widgetStorage = localStorage.getItem(`${AGENT_ID}_WEB_STORAGE`);
    const widgetData = JSON.parse(widgetStorage || '{}');

    // Show message prompts if widget was never opened
    if (!(widgetData && widgetData.CONVERSATION_BUTTON_CLICK_TIME)) {
      setTimeout(() => initMessagePrompts(), 1000);
    }

    window.addEventListener('message', function (event) {
      if (event.data && event.data.type === 'GET_PARENT_URL') {
        event.source.postMessage({
          type: 'PARENT_URL_RESPONSE',
          url: window.location.href
        }, '*');
      }
    });
  } catch (err) {
    console.error('Error loading Embedded Messaging:', err);
  }
}

// Initialize styles to show question prompts (browser only)
if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  (function () {
    injectStyles();
  })();
}
