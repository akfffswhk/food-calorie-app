"""
Test script for the hybrid AI service
"""

import asyncio
import aiohttp
import base64
from pathlib import Path


class FoodAnalyzerClient:
    """Client for testing the food analyzer API"""

    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url

    async def get_status(self) -> dict:
        """Get service status"""
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.base_url}/api/status") as response:
                return await response.json()

    async def analyze_file(self, image_path: str) -> dict:
        """Analyze food image from file"""
        async with aiohttp.ClientSession() as session:
            with open(image_path, "rb") as f:
                data = aiohttp.MultipartWriter()
                data.append_field(
                    name="image",
                    filename=Path(image_path).name,
                    content_type="image/jpeg",
                    data=f
                )

                async with session.post(
                    f"{self.base_url}/api/analyze",
                    data=data
                ) as response:
                    return await response.json()

    async def analyze_base64(self, image_path: str) -> dict:
        """Analyze food image from base64"""
        with open(image_path, "rb") as f:
            image_data = f.read()
        base64_image = base64.b64encode(image_data).decode()

        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{self.base_url}/api/analyze/base64",
                json={"image": base64_image}
            ) as response:
                return await response.json()


async def run_tests():
    """Run all tests"""
    client = FoodAnalyzerClient()

    print("=" * 60)
    print("Food Calorie Analyzer - Test Suite")
    print("=" * 60)

    # Test 1: Health check
    print("\n[1] Testing health endpoint...")
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{client.base_url}/health") as response:
                health = await response.json()
                print(f"✓ Health: {health.get('status', 'unknown')}")
    except Exception as e:
        print(f"✗ Health check failed: {e}")

    # Test 2: Service status
    print("\n[2] Checking service status...")
    try:
        status = await client.get_status()
        print("Service Status:")
        print(f"  LM Studio:      {'✓' if status.get('lm_studio') else '✗'}")
        print(f"  Hugging Face:  {'✓' if status.get('hugging_face') else '✗'}")
        print(f"  USDA:           {'✓' if status.get('usda') else '✗'}")
        print(f"  Use Local First: {status.get('use_local_first')}")
    except Exception as e:
        print(f"✗ Status check failed: {e}")

    # Test 3: Analyze with file upload
    print("\n[3] Testing file upload analysis...")
    test_image = "test_food.jpg"

    if Path(test_image).exists():
        try:
            result = await client.analyze_file(test_image)
            print("Analysis Result:")
            print(f"  Source: {result.get('source')}")
            print(f"  Processing Time: {result.get('processing_time')}s")
            print(f"  Confidence: {result.get('confidence')}")
            print(f"  Total Calories: {result.get('nutrition', {}).get('calories')} kcal")
            print("\n  Detected Items:")
            for item in result.get('items', []):
                print(f"    - {item.get('name')} ({item.get('confidence'):.0%})")
            print("\n  Nutrition:")
            nutr = result.get('nutrition', {})
            print(f"    Protein: {nutr.get('protein')}g")
            print(f"    Carbs:   {nutr.get('carbs')}g")
            print(f"    Fat:     {nutr.get('fat')}g")
        except Exception as e:
            print(f"✗ File analysis failed: {e}")
    else:
        print(f"⚠ No test image found at '{test_image}'")
        print("  Place a food image named 'test_food.jpg' in the backend directory")

    # Test 4: Analyze with base64
    print("\n[4] Testing base64 analysis...")
    if Path(test_image).exists():
        try:
            result = await client.analyze_base64(test_image)
            print(f"✓ Base64 analysis successful")
            print(f"  Source: {result.get('source')}")
            print(f"  Calories: {result.get('nutrition', {}).get('calories')} kcal")
        except Exception as e:
            print(f"✗ Base64 analysis failed: {e}")
    else:
        print("⚠ Skipped (no test image)")

    print("\n" + "=" * 60)
    print("Test suite complete!")
    print("=" * 60)


async def interactive_test():
    """Interactive test mode"""
    client = FoodAnalyzerClient()

    print("\n" + "=" * 60)
    print("Interactive Food Analyzer Test")
    print("=" * 60)

    while True:
        print("\nOptions:")
        print("1. Check service status")
        print("2. Analyze an image file")
        print("3. Exit")

        choice = input("\nSelect option (1-3): ").strip()

        if choice == "1":
            status = await client.get_status()
            print("\nService Status:")
            for key, value in status.items():
                status_icon = "✓" if value else "✗"
                print(f"  {status_icon} {key}: {value}")

        elif choice == "2":
            image_path = input("Enter image path: ").strip()
            if Path(image_path).exists():
                print("\nAnalyzing...")
                result = await client.analyze_file(image_path)

                print("\n" + "-" * 40)
                print(f"Source: {result.get('source')}")
                print(f"Processing Time: {result.get('processing_time')}s")
                print(f"Confidence: {result.get('confidence'):.0%}")
                print(f"\nTotal Calories: {result.get('nutrition', {}).get('calories')} kcal")

                print("\nDetected Items:")
                for item in result.get('items', []):
                    print(f"  • {item.get('name')} ({item.get('confidence'):.0%})")
                    print(f"    Portion: {item.get('portion')}")
                    print(f"    Estimated: {item.get('estimated_grams')}g")

                print("\nNutrition Breakdown:")
                nutr = result.get('nutrition', {})
                print(f"  Protein: {nutr.get('protein')}g")
                print(f"  Carbs:   {nutr.get('carbs')}g")
                print(f"  Fat:     {nutr.get('fat')}g")
                print(f"  Fiber:   {nutr.get('fiber')}g")
                print(f"  Sugar:   {nutr.get('sugar')}g")
            else:
                print(f"✗ File not found: {image_path}")

        elif choice == "3":
            print("\nGoodbye!")
            break

        else:
            print("Invalid option")


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "interactive":
        asyncio.run(interactive_test())
    else:
        asyncio.run(run_tests())
