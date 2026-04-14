// Import the chat channel module (but don't auto-subscribe, we do it manually from the view)
import "channels/chat_channel"

// Remove auto-subscription since we handle it manually in the view
// The chat_channel.js now exports initChatChannel instead
