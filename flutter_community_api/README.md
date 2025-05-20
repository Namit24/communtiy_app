# Flutter Community API

This is the backend API for the Flutter Community App, built with Node.js, Express, and Prisma ORM with PostgreSQL.

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- PostgreSQL database
- npm or yarn

### Installation

1. Clone the repository:
\`\`\`bash
git clone <repository-url>
cd flutter_community_api
\`\`\`

2. Install dependencies:
\`\`\`bash
npm install
\`\`\`

3. Set up environment variables:
   - Create a `.env` file in the root directory
   - Add the following variables:
\`\`\`
DATABASE_URL="postgresql://username:password@localhost:5432/flutter_community_app?schema=public"
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
PORT=3000
\`\`\`
   - Update the `DATABASE_URL` with your PostgreSQL credentials

4. Initialize the database:
\`\`\`bash
npx prisma migrate dev --name init
\`\`\`

5. Generate Prisma client:
\`\`\`bash
npx prisma generate
\`\`\`

6. Start the development server:
\`\`\`bash
npm run dev
\`\`\`

The server will start on port 3000 (or the port specified in your .env file).

## API Endpoints

### Authentication
- POST `/api/auth/register` - Register a new user
- POST `/api/auth/login` - Login a user
- PUT `/api/auth/profile` - Update user profile (requires authentication)

### Notes
- GET `/api/notes` - Get all notes (requires authentication)
- POST `/api/notes` - Create a new note (requires authentication)

### Papers
- GET `/api/papers` - Get all papers (requires authentication)
- POST `/api/papers` - Create a new paper (requires authentication)

### Skills
- GET `/api/skills` - Get all skills (requires authentication)

### Forum Posts
- GET `/api/forum-posts` - Get all forum posts (requires authentication)
- POST `/api/forum-posts` - Create a new forum post (requires authentication)

### Messages
- GET `/api/messages` - Get all conversations (requires authentication)
- GET `/api/messages/:userId` - Get messages with a specific user (requires authentication)
- POST `/api/messages` - Send a message (requires authentication)

## License

This project is licensed under the MIT License.
