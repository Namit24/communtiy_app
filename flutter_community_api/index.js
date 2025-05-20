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

// Admin middleware
const isAdmin = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
    })

    if (!user || !user.isAdmin) {
      return res.status(403).json({ error: "Admin access required" })
    }

    next()
  } catch (error) {
    console.error("Admin check error:", error)
    res.status(500).json({ error: "Server error during admin check" })
  }
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
        email: email,
      },
    })

    if (existingUser) {
      return res.status(400).json({ error: "User already exists" })
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10)

    // Check if this is the admin email
    const isAdmin = email === "namit2004nss@gmail.com"

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name: name || email.split("@")[0],
        isAdmin,
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

app.get("/api/auth/me", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id

    const user = await prisma.user.findUnique({
      where: { id: userId },
    })

    if (!user) {
      return res.status(404).json({ error: "User not found" })
    }

    // Return user data (excluding password)
    const { password: _, ...userData } = user
    res.json({ user: userData })
  } catch (error) {
    console.error("Get current user error:", error)
    res.status(500).json({ error: "Server error getting current user" })
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
    const userId = req.user.id

    // Get user's notes and notes shared with the user
    const notes = await prisma.note.findMany({
      where: {
        OR: [{ userId }, { isPublic: true }],
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

    res.json(notes)
  } catch (error) {
    console.error("Error fetching notes:", error)
    res.status(500).json({ error: "Server error fetching notes" })
  }
})

app.post("/api/notes", authenticateToken, async (req, res) => {
  try {
    const { title, subject, fileUrl, fileSize, fileType, isPublic = true } = req.body
    const userId = req.user.id

    const note = await prisma.note.create({
      data: {
        title,
        subject,
        fileUrl,
        fileSize,
        fileType,
        isPublic,
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
    const userId = req.user.id

    // Get user's papers and papers shared with the user
    const papers = await prisma.paper.findMany({
      where: {
        OR: [{ userId }, { isPublic: true }],
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

    res.json(papers)
  } catch (error) {
    console.error("Error fetching papers:", error)
    res.status(500).json({ error: "Server error fetching papers" })
  }
})

app.post("/api/papers", authenticateToken, async (req, res) => {
  try {
    const { title, subject, year, examType, fileUrl, fileSize, fileType, isPublic = true } = req.body
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
        isPublic,
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

// Skills routes (admin only for create/update/delete)
app.get("/api/skills", authenticateToken, async (req, res) => {
  try {
    const skills = await prisma.skill.findMany()
    res.json(skills)
  } catch (error) {
    console.error("Error fetching skills:", error)
    res.status(500).json({ error: "Server error fetching skills" })
  }
})

app.post("/api/skills", authenticateToken, isAdmin, async (req, res) => {
  try {
    const { title, category, description, level, estimatedTime, imageUrl } = req.body

    const skill = await prisma.skill.create({
      data: {
        title,
        category,
        description,
        level,
        estimatedTime,
        imageUrl,
        popularity: 0,
      },
    })

    res.status(201).json(skill)
  } catch (error) {
    console.error("Error creating skill:", error)
    res.status(500).json({ error: "Server error creating skill" })
  }
})

app.put("/api/skills/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params
    const { title, category, description, level, estimatedTime, imageUrl } = req.body

    const skill = await prisma.skill.update({
      where: { id },
      data: {
        title,
        category,
        description,
        level,
        estimatedTime,
        imageUrl,
      },
    })

    res.json(skill)
  } catch (error) {
    console.error("Error updating skill:", error)
    res.status(500).json({ error: "Server error updating skill" })
  }
})

app.delete("/api/skills/:id", authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params

    await prisma.skill.delete({
      where: { id },
    })

    res.json({ message: "Skill deleted successfully" })
  } catch (error) {
    console.error("Error deleting skill:", error)
    res.status(500).json({ error: "Server error deleting skill" })
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

// Message request routes
app.post("/api/messages/request", authenticateToken, async (req, res) => {
  try {
    const { receiverId } = req.body
    const senderId = req.user.id

    // Check if request already exists
    const existingRequest = await prisma.messageRequest.findFirst({
      where: {
        OR: [
          { senderId, receiverId },
          { senderId: receiverId, receiverId: senderId },
        ],
      },
    })

    if (existingRequest) {
      return res.status(400).json({ error: "Message request already exists" })
    }

    // Create message request
    const request = await prisma.messageRequest.create({
      data: {
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
        receiver: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
          },
        },
      },
    })

    res.status(201).json(request)
  } catch (error) {
    console.error("Error sending message request:", error)
    res.status(500).json({ error: "Server error sending message request" })
  }
})

app.post("/api/messages/request/:id/accept", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params
    const userId = req.user.id

    // Find the request
    const request = await prisma.messageRequest.findUnique({
      where: { id },
      include: {
        sender: true,
        receiver: true,
      },
    })

    if (!request) {
      return res.status(404).json({ error: "Message request not found" })
    }

    // Check if the user is the receiver
    if (request.receiverId !== userId) {
      return res.status(403).json({ error: "Not authorized to accept this request" })
    }

    // Update request status
    const updatedRequest = await prisma.messageRequest.update({
      where: { id },
      data: {
        status: "ACCEPTED",
      },
    })

    res.json(updatedRequest)
  } catch (error) {
    console.error("Error accepting message request:", error)
    res.status(500).json({ error: "Server error accepting message request" })
  }
})

app.post("/api/messages/request/:id/decline", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params
    const userId = req.user.id

    // Find the request
    const request = await prisma.messageRequest.findUnique({
      where: { id },
    })

    if (!request) {
      return res.status(404).json({ error: "Message request not found" })
    }

    // Check if the user is the receiver
    if (request.receiverId !== userId) {
      return res.status(403).json({ error: "Not authorized to decline this request" })
    }

    // Delete the request
    await prisma.messageRequest.delete({
      where: { id },
    })

    res.json({ message: "Message request declined" })
  } catch (error) {
    console.error("Error declining message request:", error)
    res.status(500).json({ error: "Server error declining message request" })
  }
})

// Messages routes
app.get("/api/messages", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id

    // Get all accepted message requests
    const acceptedRequests = await prisma.messageRequest.findMany({
      where: {
        OR: [{ senderId: userId }, { receiverId: userId }],
        status: "ACCEPTED",
      },
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

    // Get pending requests received by the user
    const pendingRequests = await prisma.messageRequest.findMany({
      where: {
        receiverId: userId,
        status: "PENDING",
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

    // Get the latest message for each conversation
    const conversations = await Promise.all(
      acceptedRequests.map(async (request) => {
        const otherUserId = request.senderId === userId ? request.receiverId : request.senderId
        const otherUser = request.senderId === userId ? request.receiver : request.sender

        const latestMessage = await prisma.message.findFirst({
          where: {
            OR: [
              { senderId: userId, receiverId: otherUserId },
              { senderId: otherUserId, receiverId: userId },
            ],
          },
          orderBy: { createdAt: "desc" },
        })

        // Count unread messages
        const unreadCount = await prisma.message.count({
          where: {
            senderId: otherUserId,
            receiverId: userId,
            isRead: false,
          },
        })

        return {
          id: request.id,
          userId: otherUserId,
          userName: otherUser.name,
          userAvatar: otherUser.avatarUrl,
          lastMessage: latestMessage?.content || "Start a conversation",
          timestamp: latestMessage?.createdAt || request.updatedAt,
          unreadCount,
          isOnline: false, // In a real app, you would check online status
          isAccepted: true,
        }
      }),
    )

    // Format pending requests
    const formattedRequests = pendingRequests.map((request) => ({
      id: request.id,
      userId: request.senderId,
      userName: request.sender.name,
      userAvatar: request.sender.avatarUrl,
      lastMessage: "Wants to connect with you",
      timestamp: request.createdAt,
      unreadCount: 1,
      isOnline: false,
      isAccepted: false,
    }))

    res.json([...conversations, ...formattedRequests])
  } catch (error) {
    console.error("Error fetching messages:", error)
    res.status(500).json({ error: "Server error fetching messages" })
  }
})

app.get("/api/messages/:userId", authenticateToken, async (req, res) => {
  try {
    const currentUserId = req.user.id
    const otherUserId = req.params.userId

    // Check if there's an accepted message request
    const request = await prisma.messageRequest.findFirst({
      where: {
        OR: [
          { senderId: currentUserId, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: currentUserId },
        ],
        status: "ACCEPTED",
      },
    })

    if (!request) {
      return res.status(403).json({ error: "No accepted message request found" })
    }

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

    // Check if there's an accepted message request
    const request = await prisma.messageRequest.findFirst({
      where: {
        OR: [
          { senderId, receiverId },
          { senderId: receiverId, receiverId: senderId },
        ],
        status: "ACCEPTED",
      },
    })

    if (!request) {
      return res.status(403).json({ error: "No accepted message request found" })
    }

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

// Users route (for finding users to message)
app.get("/api/users", authenticateToken, async (req, res) => {
  try {
    const currentUserId = req.user.id

    const users = await prisma.user.findMany({
      where: {
        id: { not: currentUserId },
      },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        department: true,
        year: true,
      },
    })

    res.json(users)
  } catch (error) {
    console.error("Error fetching users:", error)
    res.status(500).json({ error: "Server error fetching users" })
  }
})

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
