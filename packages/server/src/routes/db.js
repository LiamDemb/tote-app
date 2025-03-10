const express = require("express")
const router = express.Router()
const { initDatabase, models } = require("../db")
const { authenticateFirebaseToken } = require("../middleware/auth")

// Database status and initialization
router.get("/status", async (req, res) => {
    try {
        const { testConnection } = require("../db/config")
        const isConnected = await testConnection()

        res.json({
            status: isConnected ? "connected" : "disconnected",
            timestamp: new Date().toISOString(),
        })
    } catch (error) {
        console.error("Error checking database status:", error)
        res.status(500).json({ error: "Failed to check database status" })
    }
})

router.post("/init", async (req, res) => {
    try {
        const success = await initDatabase()

        if (success) {
            res.json({
                status: "success",
                message: "Database initialized successfully",
            })
        } else {
            res.status(500).json({
                status: "error",
                message: "Database initialization failed",
            })
        }
    } catch (error) {
        console.error("Error initializing database:", error)
        res.status(500).json({
            status: "error",
            message: "Database initialization failed",
            error: error.message,
        })
    }
})

// User Routes
router.post("/users", authenticateFirebaseToken, async (req, res) => {
    try {
        const userData = {
            ...req.body,
            firebaseUid: req.user.uid,
        }

        const user = await models.users.createUser(userData)
        res.status(201).json(user)
    } catch (error) {
        console.error("Error creating user:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/users/me", authenticateFirebaseToken, async (req, res) => {
    try {
        const user = await models.users.getUserByFirebaseUid(req.user.uid)

        if (!user) {
            return res.status(404).json({ error: "User not found" })
        }

        res.json(user)
    } catch (error) {
        console.error("Error getting user:", error)
        res.status(500).json({ error: error.message })
    }
})

router.put("/users/me", authenticateFirebaseToken, async (req, res) => {
    try {
        const user = await models.users.getUserByFirebaseUid(req.user.uid)

        if (!user) {
            return res.status(404).json({ error: "User not found" })
        }

        const updatedUser = await models.users.updateUserProfile(
            user.id,
            req.body
        )
        res.json(updatedUser)
    } catch (error) {
        console.error("Error updating user profile:", error)
        res.status(500).json({ error: error.message })
    }
})

// Product Routes
// router.get("/products", async (req, res) => {
//     try {
//         // Get limit from query parameter or use default
//         const limit = req.query.limit ? parseInt(req.query.limit) : 100;
//
//         const products = await models.products.getAllProducts(limit);
//         res.json(products);
//     } catch (error) {
//         console.error("Error fetching all products:", error);
//         res.status(500).json({ error: error.message });
//     }
// });

router.post("/products", authenticateFirebaseToken, async (req, res) => {
    try {
        const product = await models.products.createProduct(req.body)
        res.status(201).json(product)
    } catch (error) {
        console.error("Error creating product:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/products/:id", async (req, res) => {
    try {
        const product = await models.products.getProductById(req.params.id)

        if (!product) {
            return res.status(404).json({ error: "Product not found" })
        }

        res.json(product)
    } catch (error) {
        console.error("Error getting product:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/products/category/:category", async (req, res) => {
    try {
        const products = await models.products.getProductsByCategory(
            req.params.category
        )
        res.json(products)
    } catch (error) {
        console.error("Error getting products by category:", error)
        res.status(500).json({ error: error.message })
    }
})

// Product search with query parameter - matches frontend call
router.get("/products/search", async (req, res) => {
    try {
        const searchTerm = req.query.q || ""

        // If empty search term, return empty result
        if (!searchTerm.trim()) {
            return res.json([])
        }

        const products = await models.products.searchProducts(searchTerm)

        // If authenticated, record search
        if (req.user) {
            const searchData = {
                userId: req.user.id,
                query: searchTerm,
                resultCount: products.length,
            }

            // Don't await, let it run in background
            models.searchHistory
                .recordSearch(searchData)
                .catch((err) => console.error("Error recording search:", err))
        }

        console.log(
            `Search for "${searchTerm}" found ${products.length} results`
        )
        res.json(products)
    } catch (error) {
        console.error(`Error searching products with query parameter:`, error)
        res.status(500).json({ error: error.message })
    }
})

// Existing product search with path parameter
router.get("/products/search/:term", async (req, res) => {
    try {
        const products = await models.products.searchProducts(req.params.term)

        // If authenticated, record search
        if (req.user) {
            const searchData = {
                userId: req.user.id,
                query: req.params.term,
                resultCount: products.length,
            }

            // Don't await, let it run in background
            models.searchHistory
                .recordSearch(searchData)
                .catch((err) => console.error("Error recording search:", err))
        }

        res.json(products)
    } catch (error) {
        console.error("Error searching products:", error)
        res.status(500).json({ error: error.message })
    }
})

router.put("/products/:id", authenticateFirebaseToken, async (req, res) => {
    try {
        const product = await models.products.updateProduct(
            req.params.id,
            req.body
        )

        if (!product) {
            return res.status(404).json({ error: "Product not found" })
        }

        res.json(product)
    } catch (error) {
        console.error("Error updating product:", error)
        res.status(500).json({ error: error.message })
    }
})

router.delete("/products/:id", authenticateFirebaseToken, async (req, res) => {
    try {
        const success = await models.products.deleteProduct(req.params.id)

        if (!success) {
            return res.status(404).json({ error: "Product not found" })
        }

        res.json({ success: true })
    } catch (error) {
        console.error("Error deleting product:", error)
        res.status(500).json({ error: error.message })
    }
})

// Shopping List Routes
router.post("/shopping-lists", authenticateFirebaseToken, async (req, res) => {
    try {
        const listData = {
            ...req.body,
            userId: req.user.id,
        }

        const list = await models.shoppingLists.createShoppingList(listData)
        res.status(201).json(list)
    } catch (error) {
        console.error("Error creating shopping list:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/shopping-lists", authenticateFirebaseToken, async (req, res) => {
    try {
        const lists = await models.shoppingLists.getShoppingListsByUserId(
            req.user.id
        )
        res.json(lists)
    } catch (error) {
        console.error("Error getting shopping lists:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get(
    "/shopping-lists/:id",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const list = await models.shoppingLists.getShoppingListWithItems(
                req.params.id
            )

            if (!list) {
                return res
                    .status(404)
                    .json({ error: "Shopping list not found" })
            }

            res.json(list)
        } catch (error) {
            console.error("Error getting shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.put(
    "/shopping-lists/:id",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const list = await models.shoppingLists.updateShoppingList(
                req.params.id,
                req.body
            )

            if (!list) {
                return res
                    .status(404)
                    .json({ error: "Shopping list not found" })
            }

            res.json(list)
        } catch (error) {
            console.error("Error updating shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.delete(
    "/shopping-lists/:id",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const success = await models.shoppingLists.deleteShoppingList(
                req.params.id
            )

            if (!success) {
                return res
                    .status(404)
                    .json({ error: "Shopping list not found" })
            }

            res.json({ success: true })
        } catch (error) {
            console.error("Error deleting shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

// Shopping List Items Routes
router.post(
    "/shopping-lists/:listId/items",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const itemData = {
                ...req.body,
                listId: req.params.listId,
            }

            const item = await models.shoppingLists.addItemToList(itemData)
            res.status(201).json(item)
        } catch (error) {
            console.error("Error adding item to shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.put(
    "/shopping-lists/items/:itemId",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const item = await models.shoppingLists.updateListItem(
                req.params.itemId,
                req.body
            )

            if (!item) {
                return res.status(404).json({ error: "Item not found" })
            }

            res.json(item)
        } catch (error) {
            console.error("Error updating shopping list item:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.delete(
    "/shopping-lists/items/:itemId",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const success = await models.shoppingLists.removeListItem(
                req.params.itemId
            )

            if (!success) {
                return res.status(404).json({ error: "Item not found" })
            }

            res.json({ success: true })
        } catch (error) {
            console.error("Error removing item from shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

// Store Routes
router.get("/stores", async (req, res) => {
    try {
        const stores = await models.stores.getAllStores()
        res.json(stores)
    } catch (error) {
        console.error("Error getting stores:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/stores/:id", async (req, res) => {
    try {
        const store = await models.stores.getStoreWithLocations(req.params.id)

        if (!store) {
            return res.status(404).json({ error: "Store not found" })
        }

        res.json(store)
    } catch (error) {
        console.error("Error getting store:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/stores/nearby", async (req, res) => {
    try {
        const { latitude, longitude, radius } = req.query

        if (!latitude || !longitude) {
            return res
                .status(400)
                .json({ error: "Latitude and longitude are required" })
        }

        const stores = await models.stores.getStoreLocationsNearby(
            parseFloat(latitude),
            parseFloat(longitude),
            radius ? parseFloat(radius) : 10
        )

        res.json(stores)
    } catch (error) {
        console.error("Error getting nearby stores:", error)
        res.status(500).json({ error: error.message })
    }
})

// Price Routes
router.post("/prices", authenticateFirebaseToken, async (req, res) => {
    try {
        const priceData = {
            ...req.body,
            userId: req.user.id,
        }

        const price = await models.prices.recordPrice(priceData)
        res.status(201).json(price)
    } catch (error) {
        console.error("Error recording price:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/products/:productId/prices", async (req, res) => {
    try {
        const prices = await models.prices.getLatestPricesForProduct(
            req.params.productId
        )
        res.json(prices)
    } catch (error) {
        console.error("Error getting product prices:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get("/products/:productId/best-price", async (req, res) => {
    try {
        const { latitude, longitude, radius } = req.query

        if (!latitude || !longitude) {
            return res
                .status(400)
                .json({ error: "Latitude and longitude are required" })
        }

        const price = await models.prices.getBestPriceForProduct(
            req.params.productId,
            parseFloat(latitude),
            parseFloat(longitude),
            radius ? parseFloat(radius) : 10
        )

        if (!price) {
            return res.status(404).json({
                error: "No prices found for this product in your area",
            })
        }

        res.json(price)
    } catch (error) {
        console.error("Error getting best price for product:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get(
    "/shopping-lists/:listId/prices",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const { latitude, longitude, radius } = req.query

            if (!latitude || !longitude) {
                return res
                    .status(400)
                    .json({ error: "Latitude and longitude are required" })
            }

            const prices = await models.prices.getPricesForShoppingList(
                req.params.listId,
                parseFloat(latitude),
                parseFloat(longitude),
                radius ? parseFloat(radius) : 10
            )

            res.json(prices)
        } catch (error) {
            console.error("Error getting prices for shopping list:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

// Search History Routes
router.get("/search-history", authenticateFirebaseToken, async (req, res) => {
    try {
        const { limit } = req.query
        const history = await models.searchHistory.getUserSearchHistory(
            req.user.id,
            limit ? parseInt(limit) : 20
        )

        res.json(history)
    } catch (error) {
        console.error("Error getting search history:", error)
        res.status(500).json({ error: error.message })
    }
})

router.get(
    "/search-history/insights",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            const insights = await models.searchHistory.getUserSearchInsights(
                req.user.id
            )
            res.json(insights)
        } catch (error) {
            console.error("Error getting search insights:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.delete(
    "/search-history",
    authenticateFirebaseToken,
    async (req, res) => {
        try {
            await models.searchHistory.deleteUserSearchHistory(req.user.id)
            res.json({ success: true })
        } catch (error) {
            console.error("Error deleting search history:", error)
            res.status(500).json({ error: error.message })
        }
    }
)

router.get("/popular-searches", async (req, res) => {
    try {
        const { days, limit } = req.query
        const searches = await models.searchHistory.getPopularSearches(
            days ? parseInt(days) : 7,
            limit ? parseInt(limit) : 10
        )

        res.json(searches)
    } catch (error) {
        console.error("Error getting popular searches:", error)
        res.status(500).json({ error: error.message })
    }
})

module.exports = router
