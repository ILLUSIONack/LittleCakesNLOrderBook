const Home = () => {
  return (
    <div className="flex min-h-screen">
      {/* Left Side: 60% width with light pink background */}
      <div className="w-3/5 bg-pink-100 flex items-center justify-center p-10">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-6">LittleCakesNL</h1>
          <p className="text-xl text-pink-700 mb-1 font-extrabold">Delicious custom cakes in The Netherlands</p>
          <p className="text-lg text-gray-700 mb-4">When placing an order you agree to our terms and conditions</p>
          <a href="https://littlecakesnl.fillout.com/t/mEu3kPtDbius" rel="noopener noreferrer">
            <button className="px-6 py-3 bg-pink-500 text-white font-semibold rounded-full shadow-md hover:bg-pink-600 focus:outline-none">
              Place Your Order
            </button>
          </a>
        </div>
      </div>

      {/* Right Side: 40% width with the image */}
      <div className="w-2/5">
        <img
          src="/cakesrc.png"
          alt="Cake"
          className="object-cover w-full h-full"
        />
      </div>
    </div>
  );
};

export default Home;