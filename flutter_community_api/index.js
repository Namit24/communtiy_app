require("dotenv").config()
const express = require("express")
const cors = require("cors")
const { PrismaClient } = require("@prisma/client")
const bcrypt = require("bcrypt")
const jwt = require("jsonwebtoken")

const prisma = new PrismaClient()
const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(cors())
app.use(express.json())

// Debug middleware to log request bodies
app.use((req, res, next) => {
  if (req.method === "POST" || req.method === "PUT") {
    console.log(`Request body for ${req.path}:`, req.body)
  }
  next()
})

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"]
  const token = authHeader && authHeader.split(" ")[1]

  if (!token) return res.status(401).json({ error: "Access denied" })

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" })
    req.user = user
    next()
  })
}

// Auth routes
app.post("/api/auth/register", async (req, res) => {
  try {
    console.log("Registration request body:", req.body)
    const { email, password, name } = req.body

    // Validate required fields
    if (!email) {
      return res.status(400).json({ error: "Email is required" })
    }

    if (!password) {
      return res.status(400).json({ error: "Password is required" })
    }

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: {
        email: email, // Explicitly use the email variable
      },
    })

    if (existingUser) {
      return res.status(400).json({ error: "User already exists" })
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10)

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name: name || email.split("@")[0],
      },
    })

    // Generate token
    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || "fallback-secret-key", {
      expiresIn: "7d",
    })

    // Return user data (excluding password)
    const { password: _, ...userData } = user
    res.status(201).json({ user: userData, token })
  } catch (error) {
    console.error("Registration error:", error)
    res.status(500).json({ error: "Server error during registration" })
  }
})

app.post("/api/auth/login", async (req, res) => {
  try {
    console.log("Login request body:", req.body)
    const { email, password } = req.body

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" })
    }

    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
    })

    if (!user) {
      return res.status(400).json({ error: "Invalid credentials" })
    }

    // Check password
    const validPassword = await bcrypt.compare(password, user.password)
    if (!validPassword) {
      return res.status(400).json({ error: "Invalid credentials" })
    }

    // Generate token
    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || "fallback-secret-key", {
      expiresIn: "7d",
    })

    // Return user data (excluding password)
    const { password: _, ...userData } = user
    res.json({ user: userData, token })
  } catch (error) {
    console.error("Login error:", error)
    res.status(500).json({ error: "Server error during login" })
  }
})

app.put("/api/auth/profile", authenticateToken, async (req, res) => {
  try {
    const { name, department, year, avatarUrl } = req.body
    const userId = req.user.id

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        name,
        department,
        year,
        avatarUrl,
      },
    })

    const { password: _, ...userData } = updatedUser
    res.json({ user: userData })
  } catch (error) {
    console.error("Profile update error:", error)
    res.status(500).json({ error: "Server error during profile update" })
  }
})

// Notes routes
app.get("/api/notes", authenticateToken, async (req, res) => {
  try {
    const notes = await prisma.note.findMany({
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.json(notes)
  } catch (error) {
    console.error("Error fetching notes:", error)
    res.status(500).json({ error: "Server error fetching notes" })
  }
})

app.post("/api/notes", authenticateToken, async (req, res) => {
  try {
    const { title, subject, fileUrl, fileSize, fileType } = req.body
    const userId = req.user.id

    const note = await prisma.note.create({
      data: {
        title,
        subject,
        fileUrl,
        fileSize,
        fileType,
        uploadedBy: {
          connect: { id: userId },
        },
      },
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.status(201).json(note)
  } catch (error) {
    console.error("Error creating note:", error)
    res.status(500).json({ error: "Server error creating note" })
  }
})

// Papers routes
app.get("/api/papers", authenticateToken, async (req, res) => {
  try {
    const papers = await prisma.paper.findMany({
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.json(papers)
  } catch (error) {
    console.error("Error fetching papers:", error)
    res.status(500).json({ error: "Server error fetching papers" })
  }
})

app.post("/api/papers", authenticateToken, async (req, res) => {
  try {
    const { title, subject, year, examType, fileUrl, fileSize, fileType } = req.body
    const userId = req.user.id

    const paper = await prisma.paper.create({
      data: {
        title,
        subject,
        year,
        examType,
        fileUrl,
        fileSize,
        fileType,
        uploadedBy: {
          connect: { id: userId },
        },
      },
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.status(201).json(paper)
  } catch (error) {
    console.error("Error creating paper:", error)
    res.status(500).json({ error: "Server error creating paper" })
  }
})

// Skills routes
app.get("/api/skills", authenticateToken, async (req, res) => {
  try {
    const skills = await prisma.skill.findMany()
    res.json(skills)
  } catch (error) {
    console.error("Error fetching skills:", error)
    res.status(500).json({ error: "Server error fetching skills" })
  }
})

// Forum posts routes
app.get("/api/forum-posts", authenticateToken, async (req, res) => {
  try {
    const posts = await prisma.forumPost.findMany({
      include: {
        author: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            department: true,
          },
        },
        _count: {
          select: { comments: true },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    })

    res.json(posts)
  } catch (error) {
    console.error("Error fetching forum posts:", error)
    res.status(500).json({ error: "Server error fetching forum posts" })
  }
})

app.post("/api/forum-posts", authenticateToken, async (req, res) => {
  try {
    const { content } = req.body
    const userId = req.user.id

    const post = await prisma.forumPost.create({
      data: {
        content,
        author: {
          connect: { id: userId },
        },
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            department: true,
          },
        },
      },
    })

    res.status(201).json(post)
  } catch (error) {
    console.error("Error creating forum post:", error)
    res.status(500).json({ error: "Server error creating forum post" })
  }
})

// Messages routes
app.get("/api/messages", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id

    // Get all conversations (unique users the current user has messaged with)
    const sentMessages = await prisma.message.findMany({
      where: { senderId: userId },
      select: { receiverId: true },
      distinct: ["receiverId"],
    })

    const receivedMessages = await prisma.message.findMany({
      where: { receiverId: userId },
      select: { senderId: true },
      distinct: ["senderId"],
    })

    // Combine unique user IDs
    const userIds = new Set([...sentMessages.map((m) => m.receiverId), ...receivedMessages.map((m) => m.senderId)])

    // Get the latest message for each conversation
    const conversations = await Promise.all(
      Array.from(userIds).map(async (otherUserId) => {
        const latestMessage = await prisma.message.findFirst({
          where: {
            OR: [
              { senderId: userId, receiverId: otherUserId },
              { senderId: otherUserId, receiverId: userId },
            ],
          },
          orderBy: { createdAt: "desc" },
          include: {
            sender: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
              },
            },
            receiver: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
              },
            },
          },
        })

        // Count unread messages
        const unreadCount = await prisma.message.count({
          where: {
            senderId: otherUserId,
            receiverId: userId,
            isRead: false,
          },
        })

        // Get other user details
        const otherUser = await prisma.user.findUnique({
          where: { id: otherUserId },
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        })

        return {
          id: otherUserId,
          user: otherUser,
          lastMessage: latestMessage.content,
          timestamp: latestMessage.createdAt,
          unreadCount,
        }
      }),
    )

    res.json(conversations)
  } catch (error) {
    console.error("Error fetching messages:", error)
    res.status(500).json({ error: "Server error fetching messages" })
  }
})

app.get("/api/messages/:userId", authenticateToken, async (req, res) => {
  try {
    const currentUserId = req.user.id
    const otherUserId = req.params.userId

    const messages = await prisma.message.findMany({
      where: {
        OR: [
          { senderId: currentUserId, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: currentUserId },
        ],
      },
      orderBy: { createdAt: "asc" },
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    // Mark messages as read
    await prisma.message.updateMany({
      where: {
        senderId: otherUserId,
        receiverId: currentUserId,
        isRead: false,
      },
      data: { isRead: true },
    })

    res.json(messages)
  } catch (error) {
    console.error("Error fetching conversation:", error)
    res.status(500).json({ error: "Server error fetching conversation" })
  }
})

app.post("/api/messages", authenticateToken, async (req, res) => {
  try {
    const { receiverId, content } = req.body
    const senderId = req.user.id

    const message = await prisma.message.create({
      data: {
        content,
        sender: {
          connect: { id: senderId },
        },
        receiver: {
          connect: { id: receiverId },
        },
      },
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.status(201).json(message)
  } catch (error) {
    console.error("Error sending message:", error)
    res.status(500).json({ error: "Server error sending message" })
  }
})

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
