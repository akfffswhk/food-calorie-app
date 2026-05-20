"""
MongoDB database connection and utilities
Supports two databases: users and records
"""

from motor.motor_asyncio import AsyncIOMotorClient
from typing import Optional
import os


class Database:
    """MongoDB database manager for multiple databases"""

    # Users database
    users_client: Optional[AsyncIOMotorClient] = None
    users_database = None

    # Records database
    records_client: Optional[AsyncIOMotorClient] = None
    records_database = None

    @classmethod
    async def connect(cls):
        """Connect to both MongoDB databases"""
        # Users database
        users_uri = os.getenv(
            "MONGODB_USERS_URI",
            "mongodb://localhost:27017"
        )
        users_db_name = os.getenv("MONGODB_USERS_DB_NAME", "food_users")

        cls.users_client = AsyncIOMotorClient(users_uri)
        cls.users_database = cls.users_client[users_db_name]

        # Records database
        records_uri = os.getenv(
            "MONGODB_RECORDS_URI",
            "mongodb://localhost:27018"
        )
        records_db_name = os.getenv("MONGODB_RECORDS_DB_NAME", "food_records")

        cls.records_client = AsyncIOMotorClient(records_uri)
        cls.records_database = cls.records_client[records_db_name]

        # Create indexes
        await cls._create_indexes()

        print(f"Connected to MongoDB - Users: {users_db_name}, Records: {records_db_name}")

    @classmethod
    async def disconnect(cls):
        """Disconnect from both MongoDB databases"""
        if cls.users_client:
            cls.users_client.close()
            print("Disconnected from Users MongoDB")

        if cls.records_client:
            cls.records_client.close()
            print("Disconnected from Records MongoDB")

    @classmethod
    async def _create_indexes(cls):
        """Create database indexes"""
        try:
            # Users database indexes
            await cls.users_database.users.create_index("email", unique=True)
            await cls.users_database.users.create_index("username", unique=True, sparse=True)
            await cls.users_database.users.create_index("created_at")
        except Exception as e:
            print(f"Warning: Could not create users indexes: {e}")

        try:
            # Records database indexes
            await cls.records_database.analyses.create_index([("user_id", 1), ("created_at", -1)])
            await cls.records_database.analyses.create_index([("user_id", 1), ("date", 1)])
            await cls.records_database.analyses.create_index("created_at")

            await cls.records_database.suggestions.create_index([("user_id", 1), ("type", 1)])
            await cls.records_database.suggestions.create_index("created_at")

            await cls.records_database.daily_summaries.create_index(
                [("user_id", 1), ("date", 1)],
                unique=True
            )
            await cls.records_database.daily_summaries.create_index("date")
        except Exception as e:
            print(f"Warning: Could not create records indexes: {e}")

    @classmethod
    def get_users_db(cls):
        """Get users database instance"""
        if cls.users_database is None:
            raise RuntimeError("Users database not connected. Call connect() first.")
        return cls.users_database

    @classmethod
    def get_records_db(cls):
        """Get records database instance"""
        if cls.records_database is None:
            raise RuntimeError("Records database not connected. Call connect() first.")
        return cls.records_database


# Collection helpers - Users Database
def get_users_collection():
    """Get users collection"""
    return Database.get_users_db().users


def get_sessions_collection():
    """Get sessions collection"""
    return Database.get_users_db().sessions


# Collection helpers - Records Database
def get_analyses_collection():
    """Get analyses collection"""
    return Database.get_records_db().analyses


def get_suggestions_collection():
    """Get suggestions collection"""
    return Database.get_records_db().suggestions


def get_daily_summaries_collection():
    """Get daily summaries collection"""
    return Database.get_records_db().daily_summaries
