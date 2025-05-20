Flutter Community App
Overview
The Flutter Community App is a cross-platform mobile and web application designed for students to connect, share academic resources, and discuss skills. Built with Flutter for the frontend and a Node.js backend with Prisma ORM, the app supports Android, iOS, web, Linux, macOS, and Windows platforms. It provides a seamless user experience for academic collaboration, including features like user authentication, note sharing, past paper uploads, skill discussions, and real-time messaging.
Features
1. User Authentication

Registration and Login: Users can sign up with an email and password, and log in securely using JWT-based authentication.
Profile Management: Users can update their profile details, including name, department, year, and avatar.

2. Notes Sharing

Upload and View Notes: Students can upload notes with details like title, subject, file URL, size, and type. All notes are accessible to authenticated users.
User Attribution: Notes display the uploader’s name and avatar for community engagement.

3. Past Papers

Upload and Browse Papers: Users can share past exam papers, specifying title, subject, year, exam type, file URL, size, and type.
Organized Access: Papers are categorized and accessible with uploader details.

4. Skills Discussion

Skill Listings: Users can explore and discuss various skills, with detailed views for each skill.
Community Interaction: Encourages collaboration through skill-focused discussions.

5. Messaging

Real-Time Chat: Users can engage in one-on-one or group chats to discuss academic topics.
Chat Interface: Features a clean chat UI with message bubbles and chat list items.

6. Cross-Platform Support

Runs on Android, iOS, web, Linux, macOS, and Windows, ensuring accessibility across devices.
Optimized for performance with Flutter’s HTML renderer for web compatibility.

7. User Interface

Material Design: Utilizes Flutter’s Material Design for a modern, consistent UI.
Custom Widgets: Includes reusable widgets like CustomButton, ProfileAvatar, NoteCard, PaperCard, and SkillCard for a cohesive look.
Theming: Supports light and dark themes, with Google Fonts (Poppins) for typography.

8. Backend Integration

Node.js API: A robust backend with Express.js and Prisma ORM for database management.
Secure API Routes: Authentication middleware ensures secure access to notes, papers, and skills endpoints.
Environment Configuration: Uses dotenv for secure environment variable management.

Installation
Prerequisites

Flutter: Version 3.27.0 or higher
Dart: Version 3.7.0 or higher
Node.js: Version 18 or higher
NPM: For backend dependencies
Database: A Prisma-compatible database (e.g., PostgreSQL, MySQL)

Setup Instructions

Clone the Repository
git clone https://github.com/your-repo/flutter_community_app.git
cd flutter_community_app


Install Flutter Dependencies
flutter pub get


Set Up the Backend

Navigate to the flutter_community_api directory:cd flutter_community_api
npm install


Configure environment variables in a .env file:PORT=3000
JWT_SECRET=your_jwt_secret_key
DATABASE_URL=your_database_connection_string


Initialize the database with Prisma:npx prisma migrate dev


Start the backend server:node index.js




Run the Flutter App

Return to the root directory:cd ..


Run the app on your desired platform:flutter run





Building for Specific Platforms

Android: Ensure Android SDK is configured. Run flutter build apk for release builds.
iOS: Configure Xcode and run flutter build ios.
Web: Use flutter build web and serve the build/web directory.
Desktop: Use flutter build linux, flutter build macos, or flutter build windows.

Usage

Sign Up/Login: Create an account or log in using your credentials.
Profile Setup: Complete your profile with department, year, and avatar.
Explore Features:
Notes: Upload or browse shared notes in the Notes section.
Papers: Share or view past papers in the Papers section.
Skills: Explore skills or start discussions in the Skills section.
Messages: Connect with other users via the Messages section.


Navigation: Use the bottom navigation bar to switch between Home, Notes, Papers, Skills, and Messages.

Project Structure

lib/: Contains Flutter source code, including:
main.dart: Entry point of the app.
models/: Data models for chat, forum posts, notes, papers, skills, and users.
screens/: UI screens for authentication, home, notes, papers, skills, and messaging.
services/: API, authentication, and data services.
widgets/: Reusable UI components.


flutter_community_api/: Node.js backend with Express.js and Prisma.
android/, ios/, web/, linux/, macos/, windows/: Platform-specific configurations.

Contributing
Contributions are welcome! Please follow these steps:

Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit your changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a pull request.


Contact
For issues or suggestions, open an issue on the GitHub repository or contact the maintainer at [namit2004nss@gmail.com].
