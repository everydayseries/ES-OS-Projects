import { useState } from "react";
import logo from "./assets/whatai.png";
import axios from "axios"; // Axios for API calls
import img1 from "./assets/1.png";
import img2 from "./assets/2.png";
import img3 from "./assets/3.png";

function App() {
  const [file, setFile] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [apiResponse, setApiResponse] = useState(null);
  const [dragOver, setDragOver] = useState(false);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile && selectedFile.type === "application/zip") {
      setFile(selectedFile);
    } else {
      alert("Please upload a valid .zip file.");
    }
  };


  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile && droppedFile.type === "application/zip") {
      setFile(droppedFile);
    } else {
      alert("Please upload a valid .zip file.");
    }
    setDragOver(false);
  };


  const handleProcess = async () => {
    if (!file) {
      alert("Please upload a .zip file before processing.");
      return;
    }
    setIsLoading(true);
    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await axios.post(
        "http://127.0.0.1:5000/upload_zip",
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        }
      );
      setApiResponse(response.data);
    } catch (error) {
      console.error("Error uploading file:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      <div className="flex w-full h-full font-poppins bg-[#FFEED5] pb-[200px]">
        <div className="flex w-full h-full flex-col">

          <div className="flex flex-row items-center px-[50px] pt-[30px]">
            <img src={logo} className="w-[80px] h-fit"></img>
            <p className="ml-[10px] text-[28px] font-semibold font-poppins ">
              <span className="text-transparent bg-clip-text bg-gradient-to-b from-[#23B23B] to-[#0F4C19]">
                Whats
              </span>
              <span className="text-[#06581F]">AI</span>
            </p>
          </div>

          {/* Hero Section */}
          <div className="flex justify-center items-center mt-[60px] flex-col">
            <p className="text-[48px] font-bold font-poppins ">
              I want to look for <span className="text-[#FF7143]">leads</span>
              <span className="text-[40px]"></span>
            </p>

            {/* Drag & Drop or Upload Section */}
            <div
              className={`flex items-center justify-center w-[600px] h-[50px]  mt-[20px] shadow-xl ${
                dragOver ? "border-green-500" : "border-gray-300"
              } rounded-xl  bg-white cursor-pointer shadow-lg`}
              onDragOver={handleDragOver}
              onDrop={handleDrop}
            >
              <input
                type="file"
                accept=".zip"
                onChange={handleFileChange}
                className="hidden"
                id="file-upload"
              />
              <label
                htmlFor="file-upload"
                className="w-full flex justify-between items-center"
              >
                <span className="text-[#ACACAC] ml-[20px] ">
                  {file ? file.name : "Select or Drag your chat.zip archive"}
                </span>
                <button
                  onClick={handleProcess}
                  className="bg-[#297E43] text-white font-semibold h-[50px] px-[20px] rounded-lg shadow-lg flex items-center"
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <>
                      Processing{" "}
                      <span className="ml-2 loader">
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          viewBox="0 0 24 24"
                          fill="currentColor"
                          className="text-white w-6 h-6 ml-[5px] animate-spin"
                        >
                          <path d="M5.46257 4.43262C7.21556 2.91688 9.5007 2 12 2C17.5228 2 22 6.47715 22 12C22 14.1361 21.3302 16.1158 20.1892 17.7406L17 12H20C20 7.58172 16.4183 4 12 4C9.84982 4 7.89777 4.84827 6.46023 6.22842L5.46257 4.43262ZM18.5374 19.5674C16.7844 21.0831 14.4993 22 12 22C6.47715 22 2 17.5228 2 12C2 9.86386 2.66979 7.88416 3.8108 6.25944L7 12H4C4 16.4183 7.58172 20 12 20C14.1502 20 16.1022 19.1517 17.5398 17.7716L18.5374 19.5674Z"></path>
                        </svg>
                      </span>
                    </>
                  ) : (
                    <>
                      Process{" "}
                      <span className="ml-[5px] flex items-center justify-center">
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          viewBox="0 0 24 24"
                          fill="currentColor"
                          className="text-white w-6 h-6 ml-[5px]"
                        >
                          <path d="M1.94619 9.31543C1.42365 9.14125 1.41953 8.86022 1.95694 8.68108L21.0431 2.31901C21.5716 2.14285 21.8747 2.43866 21.7266 2.95694L16.2734 22.0432C16.1224 22.5716 15.8178 22.59 15.5945 22.0876L12 14L18 6.00005L10 12L1.94619 9.31543Z"></path>
                        </svg>
                      </span>
                    </>
                  )}
                </button>
              </label>
            </div>
          </div>

          {/* Conditionally show How-to section or API response */}
          {!apiResponse ? (
            <div className="flex flex-col mt-[50px]">
              <p className="text-[25px] font-semibold w-full text-center">
                How to download your chat archive?
              </p>

              <div className="flex  text-[18px] flex-row justify-between lg:mx-[200px] mt-[30px] items-center">
                <div className="flex flex-col items-center">
                  <img src={img1} className="w-[250px] h-fit"></img>
                  <p className="text-center font-medium mt-[10px]">
                    Select the chat you want to analyze
                  </p>
                </div>
                <div className="flex flex-col items-center">
                  <img src={img2} className="w-[250px] h-fit"></img>
                  <p className="text-center font-medium mt-[10px]">
                    Go to chat details
                  </p>
                </div>
                <div className="flex flex-col items-center">
                  <img src={img3} className="w-[250px] h-fit"></img>
                  <p className="text-center font-medium mt-[10px]">
                    Click on Export Chat and upload
                  </p>
                </div>
              </div>
            </div>
          ) : (
            <div className="mt-[50px] p-[30px] mx-[50px]">
              <p className="text-[25px] font-semibold">
                Leads found: <span className="text-[#06581F] text-[35px]">{apiResponse.number_of_leads}</span>
              </p>
              <div className="mt-[20px] grid grid-cols-1 gap-[20px]">
                {apiResponse.messages.map((msg, index) => (
                  <div
                    key={index}
                    className="p-[15px] bg-white rounded-md "
                  >
                     <p className="text-[15px] font-medium mb-[5px] text-[#6c6b6b]">
                      {msg.time}
                    </p>
                    <p className="text-[18px] font-semibold mb-[5px] text-[#06581F]">
                      {msg.sender}
                    </p>
                    <p className="text-[18px] font-regular mb-[5px]">
                      {msg.message_without_time}
                    </p>
                   
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

export default App;
