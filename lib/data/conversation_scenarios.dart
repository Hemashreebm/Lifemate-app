import 'package:flutter/material.dart';
import '../models/conversation_scenario.dart';

/// Built-in beginner practice conversations for Daily Conversation feature.
class ConversationScenariosData {
  static const List<ConversationScenario> scenarios = [
    // 1. Shopping
    ConversationScenario(
      id: 'shopping',
      title: 'Shopping',
      subtitle: 'Ask about products and prices',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF0284C7),
      turns: [
        ConversationTurn(
          lifemateLine: 'Hello! Welcome to our store. How can I help you today?',
          suggestedReply: 'I am looking for a shirt.',
          simpleMeaning: 'You are telling the shopkeeper what you want to buy.',
        ),
        ConversationTurn(
          lifemateLine: 'Great! What size do you need?',
          suggestedReply: 'I need a medium size.',
          simpleMeaning: 'You are stating your clothing size.',
        ),
        ConversationTurn(
          lifemateLine: 'We have medium in blue, black, and white. Which color do you prefer?',
          suggestedReply: 'I would like the blue one.',
          simpleMeaning: 'You are choosing your favorite color.',
        ),
        ConversationTurn(
          lifemateLine: 'Here is the blue shirt. Would you like to try it on?',
          suggestedReply: 'Yes, where is the fitting room?',
          simpleMeaning: 'You are asking where to try on the clothes.',
        ),
        ConversationTurn(
          lifemateLine: 'The fitting room is right on the left side.',
          suggestedReply: 'Thank you! How much does this shirt cost?',
          simpleMeaning: 'You are asking for the price of the item.',
        ),
        ConversationTurn(
          lifemateLine: 'It is 500 rupees. We accept cash or UPI card payment.',
          suggestedReply: 'I will pay with cash. Here is 500 rupees.',
          simpleMeaning: 'You are completing your payment.',
        ),
      ],
    ),

    // 2. College
    ConversationScenario(
      id: 'college',
      title: 'College',
      subtitle: 'Talk with classmates and teachers',
      icon: Icons.school_rounded,
      color: Color(0xFF7C3AED),
      turns: [
        ConversationTurn(
          lifemateLine: 'Hi! Are you a student in the Computer Science department?',
          suggestedReply: 'Yes, I am in the CS department.',
          simpleMeaning: 'You are confirming your college department.',
        ),
        ConversationTurn(
          lifemateLine: 'Nice! Which class do we have next?',
          suggestedReply: 'We have Python Programming class next.',
          simpleMeaning: 'You are telling your friend the subject of the next lecture.',
        ),
        ConversationTurn(
          lifemateLine: 'Do you know which room the class is in?',
          suggestedReply: 'It is in Lab Room 302.',
          simpleMeaning: 'You are sharing the location of the classroom.',
        ),
        ConversationTurn(
          lifemateLine: 'Thanks! Did you complete the assignment for today?',
          suggestedReply: 'Yes, I finished it last night.',
          simpleMeaning: 'You are saying that your homework is ready.',
        ),
        ConversationTurn(
          lifemateLine: 'Awesome! Can we sit together in class?',
          suggestedReply: 'Sure, let us go inside together.',
          simpleMeaning: 'You are inviting your friend to sit together.',
        ),
      ],
    ),

    // 3. Restaurant
    ConversationScenario(
      id: 'restaurant',
      title: 'Restaurant',
      subtitle: 'Order food confidently',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFEA580C),
      turns: [
        ConversationTurn(
          lifemateLine: 'Good afternoon! Table for how many people?',
          suggestedReply: 'Table for two people, please.',
          simpleMeaning: 'You are asking for seating for 2 persons.',
        ),
        ConversationTurn(
          lifemateLine: 'Right this way. Here is your menu. Are you ready to order drinks?',
          suggestedReply: 'I would like water and fresh lime juice.',
          simpleMeaning: 'You are ordering your initial beverage drinks.',
        ),
        ConversationTurn(
          lifemateLine: 'Lime juice and water. What would you like for your main dish?',
          suggestedReply: 'I would like vegetable fried rice.',
          simpleMeaning: 'You are ordering your main meal dish.',
        ),
        ConversationTurn(
          lifemateLine: 'Would you like that spicy or medium spicy?',
          suggestedReply: 'Medium spicy, please.',
          simpleMeaning: 'You are specifying your food taste preference.',
        ),
        ConversationTurn(
          lifemateLine: 'Your order will be ready in 15 minutes. Enjoy your meal!',
          suggestedReply: 'Thank you very much. Could we get the bill later?',
          simpleMeaning: 'You are politely thanking the server.',
        ),
      ],
    ),

    // 4. Travel
    ConversationScenario(
      id: 'travel',
      title: 'Travel',
      subtitle: 'Ask for directions and travel information',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF059669),
      turns: [
        ConversationTurn(
          lifemateLine: 'Excuse me! Can I help you find your destination?',
          suggestedReply: 'Where is the main bus station?',
          simpleMeaning: 'You are asking for directions to the bus station.',
        ),
        ConversationTurn(
          lifemateLine: 'The main station is about 10 minutes from here. Are you walking?',
          suggestedReply: 'No, I want to take an auto or taxi.',
          simpleMeaning: 'You are explaining how you plan to travel.',
        ),
        ConversationTurn(
          lifemateLine: 'You can catch an auto right across the road.',
          suggestedReply: 'Which bus goes to the airport?',
          simpleMeaning: 'You are asking for bus route details.',
        ),
        ConversationTurn(
          lifemateLine: 'Bus number 101 goes directly to the airport.',
          suggestedReply: 'Thank you for your help!',
          simpleMeaning: 'You are expressing appreciation for guidance.',
        ),
      ],
    ),

    // 5. Hospital
    ConversationScenario(
      id: 'hospital',
      title: 'Hospital',
      subtitle: 'Explain simple needs and symptoms',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFE11D48),
      turns: [
        ConversationTurn(
          lifemateLine: 'Hello. Welcome to the reception. Do you have an appointment?',
          suggestedReply: 'I want to see a doctor for a headache.',
          simpleMeaning: 'You are stating your health problem and medical need.',
        ),
        ConversationTurn(
          lifemateLine: 'I understand. How long have you had this headache?',
          suggestedReply: 'Since yesterday morning.',
          simpleMeaning: 'You are explaining when your symptoms started.',
        ),
        ConversationTurn(
          lifemateLine: 'Please fill out this registration form. Is this your first visit?',
          suggestedReply: 'Yes, this is my first time here.',
          simpleMeaning: 'You are providing patient registration information.',
        ),
        ConversationTurn(
          lifemateLine: 'Dr. Sharma is available. Please wait in Room 5.',
          suggestedReply: 'Thank you. I will wait in Room 5.',
          simpleMeaning: 'You are acknowledging where to wait.',
        ),
      ],
    ),

    // 6. Meeting Someone
    ConversationScenario(
      id: 'meeting',
      title: 'Meeting Someone',
      subtitle: 'Introduce yourself and make conversation',
      icon: Icons.handshake_rounded,
      color: Color(0xFFD97706),
      turns: [
        ConversationTurn(
          lifemateLine: 'Hello! I do not think we have met before. I am Alex.',
          suggestedReply: 'Hi Alex! Nice to meet you. I am Hema.',
          simpleMeaning: 'You are introducing yourself by name.',
        ),
        ConversationTurn(
          lifemateLine: 'Nice to meet you Hema! Where are you from?',
          suggestedReply: 'I am from Hyderabad.',
          simpleMeaning: 'You are telling your home city or hometown.',
        ),
        ConversationTurn(
          lifemateLine: 'Hyderabad is a lovely city! What do you do for work or study?',
          suggestedReply: 'I am studying computer applications.',
          simpleMeaning: 'You are sharing your current field of study or profession.',
        ),
        ConversationTurn(
          lifemateLine: 'That sounds exciting! What hobbies do you enjoy in your free time?',
          suggestedReply: 'I enjoy reading books and listening to music.',
          simpleMeaning: 'You are talking about your favorite hobbies.',
        ),
        ConversationTurn(
          lifemateLine: 'It was great chatting with you! Hope to see you again soon.',
          suggestedReply: 'It was great meeting you too. Have a nice day!',
          simpleMeaning: 'You are closing the conversation politely.',
        ),
      ],
    ),

    // 7. Phone Call
    ConversationScenario(
      id: 'phone',
      title: 'Phone Call',
      subtitle: 'Practice simple phone conversations',
      icon: Icons.phone_in_talk_rounded,
      color: Color(0xFF4F46E5),
      turns: [
        ConversationTurn(
          lifemateLine: 'Hello! Thank you for calling Tech Support. Who am I speaking with?',
          suggestedReply: 'Hello, my name is Hema.',
          simpleMeaning: 'You are stating your identity over the phone.',
        ),
        ConversationTurn(
          lifemateLine: 'Hi Hema! How can I assist you with your device today?',
          suggestedReply: 'My internet connection is not working.',
          simpleMeaning: 'You are reporting an issue with your service.',
        ),
        ConversationTurn(
          lifemateLine: 'I can help with that. Could you please restart your router?',
          suggestedReply: 'Okay, I will restart it now.',
          simpleMeaning: 'You are agreeing to perform the troubleshooting step.',
        ),
        ConversationTurn(
          lifemateLine: 'Is the light green now on your router?',
          suggestedReply: 'Yes! It is working now. Thank you!',
          simpleMeaning: 'You are confirming that the issue is resolved.',
        ),
      ],
    ),

    // 8. Workplace
    ConversationScenario(
      id: 'workplace',
      title: 'Workplace',
      subtitle: 'Practice everyday professional English',
      icon: Icons.work_rounded,
      color: Color(0xFF0F766E),
      turns: [
        ConversationTurn(
          lifemateLine: 'Good morning! Did you get a chance to review the project report?',
          suggestedReply: 'Good morning! Yes, I reviewed it this morning.',
          simpleMeaning: 'You are confirming completion of a workplace task.',
        ),
        ConversationTurn(
          lifemateLine: 'Great. Do you have any feedback or questions regarding the timeline?',
          suggestedReply: 'Everything looks clear. I think we can finish on time.',
          simpleMeaning: 'You are expressing confidence in project deadlines.',
        ),
        ConversationTurn(
          lifemateLine: 'Excellent work. Can you send the final file to the team via email?',
          suggestedReply: 'Sure, I will send the email right now.',
          simpleMeaning: 'You are committing to complete the administrative task.',
        ),
        ConversationTurn(
          lifemateLine: 'Thank you for your prompt response!',
          suggestedReply: 'You are welcome! Let me know if you need anything else.',
          simpleMeaning: 'You are providing supportive professional assistance.',
        ),
      ],
    ),
  ];
}
