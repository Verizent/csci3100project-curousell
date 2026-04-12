import consumer from "channels/consumer"

// Make App available globally
window.App = window.App || {};
App.cable = consumer;

// This will be called manually from the view for dynamic conversation IDs
window.initChatChannel = function(conversationId) {
  return consumer.subscriptions.create({ channel: "ChatChannel", conversation_id: conversationId }, {
    connected() {
      console.log("Connected to chat channel", conversationId);
    },
    disconnected() {
      console.log("Disconnected from chat channel");
    },
    received(data) {
      console.log("Received:", data);
      const container = document.querySelector('.messages-container');
      if (container) {
        container.insertAdjacentHTML('beforeend', data.message);
        document.getElementById('message-input').value = '';
      }
    },
    speak(message) {
      return this.perform('speak', { message: message });
    }
  });
};
