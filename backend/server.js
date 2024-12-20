import express from 'express';
import Moralis from 'moralis';
import dotenv from 'dotenv';

dotenv.config();

const app = express();

// Middleware for parsing JSON request bodies (optional, based on your requirements)
app.use(express.json());

// Initialize Moralis
const MORALIS_API_KEY = process.env.MORALIS_API_KEY;
await Moralis.start({
    apiKey: MORALIS_API_KEY,
});

// Define the route
app.post('/get_token_balance', async (req, res) => {
    const { address, chain } = req.body;

  try {
        // Call Moralis API to get the native balance
        const response = await Moralis.EvmApi.balance.getNativeBalance({
            chain: chain,
            address: address,
        });

        // Send the balance as the response
        res.status(200).json({
            success: true,
            result: response.raw,
        });
    } catch (error) {
        console.error('Error fetching balance:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch balance',
            error: error.message,
        });
    }
});

app.post('/get_user_nfts', async (req, res) => {
    const { address, chain } = req.body;

    console.log('Received request to fetch NFTs for address:', address);

    try {
        const response = await Moralis.EvmApi.nft.getWalletNFTs({
            chain: chain,
            address: address,
            mediaItems: true,
            format: 'decimal',
        });

        // const response = await Moralis.EvmApi.nft.getWalletNFTs({
        //   "chain": chain,
        //   "format": "decimal",
        //   "mediaItems": true,
        //   "address": address,
        // });

        res.status(200).json({
            success: true,
            result: response.raw,
        });

        // console.log(response.raw);
    } catch (error) {
        console.log('Error fetching NFTs:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch NFTs',
            error: error.message,
        });
    }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});
