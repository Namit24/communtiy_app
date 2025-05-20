// test-db.js
require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

async function testConnection() {
    const prisma = new PrismaClient();
    try {
        // Try a simple query
        const result = await prisma.$queryRaw`SELECT 1 as result`;
        console.log('Database connection successful:', result);
    } catch (error) {
        console.error('Database connection failed:', error);
    } finally {
        await prisma.$disconnect();
    }
}

testConnection();