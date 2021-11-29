// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomSVG is ERC721URIStorage, VRFConsumerBase, Ownable {
    uint256 public tokenCounter;

    event CreatedRandomSVG(uint256 indexed tokenId, string tokenURI);
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 randomNumber);
    event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId); 
    mapping(bytes32 => address) public requestIdToSender;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public maxNumberOfPaths;
    uint256 public maxNumberOfPathCommands;
    uint256 public size;
    string[] public pathCommands;
    string[] public colors;



    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, uint256 _fee) 
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("RandomSVG", "rsNFT")
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = _fee;
        maxNumberOfPaths = 10;
        maxNumberOfPathCommands = 5;
        size = 500;
        pathCommands = ["M", "L"];
        colors = ["red", "blue", "green", "yellow", "black", "white"];
    }

    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function create() public returns (bytes32 requestId) {
        requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        uint256 tokenId = tokenCounter; 
        requestIdToTokenId[requestId] = tokenId;
        tokenCounter = tokenCounter + 1;
        emit requestedRandomSVG(requestId, tokenId);
    }

    function finishMint(uint256 tokenId) public {
        require(bytes(tokenURI(tokenId)).length <= 0, "tokenURI is already set!"); 
        require(tokenCounter > tokenId, "TokenId has not been minted yet!");
        require(tokenIdToRandomNumber[tokenId] > 0, "Need to wait for the Chainlink node to respond!");
        uint256 randomNumber = tokenIdToRandomNumber[tokenId];
        string memory svg = generateSVG(randomNumber);
        string memory imageURI = svgToImageURI(svg);
        _setTokenURI(tokenId, formatTokenURI(imageURI));
        emit CreatedRandomSVG(tokenId, svg);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        address nftOwner = requestIdToSender[requestId];
        uint256 tokenId = requestIdToTokenId[requestId];
        _safeMint(nftOwner, tokenId);
        tokenIdToRandomNumber[tokenId] = randomNumber;
        emit CreatedUnfinishedRandomSVG(tokenId, randomNumber);
    }

    function generateSVG(uint256 _randomness) public view returns (string memory finalSvg) {

    string memory hexStringBody = string(abi.encodePacked("#")); //string(abi.encodePacked("#")); //initializing hexStringBody as a string
    string memory hexStringSpots = string(abi.encodePacked("#")); // string(abi.encodePacked("#")); //initializing hexStringSpots as a string
        
        for(uint8 i = 0; i < 6; i++) { //while we haven't gotten 6 digits yet...
            uint256 hexDigit = _randomness % 16; //a hex digit = a random number between 0-15
            if(hexDigit >= 10) {//if we get a value greater than or equal to 10(meaning A-F in hex)
                hexStringBody = string(abi.encodePacked(uint2str(hexDigit))); //Converts our int to str, concatenates to hexStringBody
            }
            else {
                hexStringBody = string(abi.encodePacked(hexDigit)); //concatenate 1 hex digit to the hex color string
            }
        }

        for(uint8 i = 0; i < 6; i++) { //while we haven't gotten 6 digits yet...
            uint256 hexDigit = _randomness % 16; //a hex digit = a random number between 0-15
            if(hexDigit >= 10) {//if we get a value greater than or equal to 10(meaning A-F in hex)

                    hexStringBody = string(abi.encodePacked(uint2str(hexDigit)));
                }
            else {
                hexStringBody = string(abi.encodePacked(hexDigit));
            }
        }

        //need to import SVG into a string
        string memory importSVG = string(abi.encodePacked("<svg id='milker_1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 640 480' shape-rendering='geometricPrecision' text-rendering='geometricPrecision'><g id='milker_1-g1'><rect id='milker_1-rect1' width='640' height='480' rx='0' ry='0' fill='rgb(121,163,248)' stroke='none' stroke-width='0'/><rect id='milker_1-rect2' width='640' height='109.160935' rx='0' ry='0' transform='matrix(1 0 0 1 0 370.839066)' fill='rgb(18,163,49)' stroke='none' stroke-width='0'/></g><rect id='milker_1-leg4' width='24.759285' height='84.731775' rx='0' ry='0' transform='matrix(1 0 0 1 320.000001 359.834939)' fill=hexStringBody stroke='none' stroke-width='0'/><rect id='milker_1-leg3' width='24.759285' height='84.731775' rx='0' ry='0' transform='matrix(1 0 0 1 369.518572 371.389271)' fill=hexStringBody stroke='none' stroke-width='0'/><rect id='milker_1-leg2' width='24.759285' height='84.731775' rx='0' ry='0' transform='matrix(1 0 0 1 480.66025 328.473179)' fill=hexStringBody stroke='none' stroke-width='0'/><ellipse id='milker_1-udder' rx='34.662999' ry='27.510317' transform='matrix(1 0 0 1 505.419535 374.69051)' fill='rgb(251,93,228)' stroke='none' stroke-width='0'/><rect id='milker_1-leg1' width='24.759285' height='84.731775' rx='0' ry='0' transform='matrix(1 0 0 1 516.973867 354.883081)' fill=hexStringBody stroke='none' stroke-width='0'/><ellipse id='milker_1-body' rx='128.748281' ry='78.624484' transform='matrix(1 0 0 1 429.49106 318.624484)' fill=hexStringBody stroke='none' stroke-width='0'/><path id='milker_1-rightear' d='M313.94773,206.87758C357.03479,155.17311,373.8559,206.87758,313.94773,206.87758' transform='matrix(-0.563424 -0.826168 0.826168 -0.563424 303.961842 573.939268)' fill='rgb(241,233,233)' stroke='none' stroke-width='3'/><ellipse id='milker_1-head' rx='46.767538' ry='55.570839' transform='matrix(1 0 0 1 297.991748 240)' fill=hexStringBody stroke='none' stroke-width='0'/><path id='milker_1-leftear' d='M313.94773,206.87758C357.03479,155.17311,373.8559,206.87758,313.94773,206.87758' transform='matrix(1 0 0 1 18.431914 7.356637)' fill='rgb(241,233,233)' stroke='none' stroke-width='3'/><path id='milker_1-leftear2' d='M313.94773,206.87758C357.03479,155.17311,373.8559,206.87758,313.94773,206.87758' transform='matrix(1 0 0 1 18.431914 7.356637)' fill='rgb(241,233,233)' stroke='none' stroke-width='3'/><ellipse id='milker_1-snout' rx='35.318756' ry='34.057771' transform='matrix(1 0 0 1 277.739664 274.057772)' fill='rgb(177,177,108)' stroke='none' stroke-width='0'/> <ellipse id='milker_1-righteye' rx='9.730816' ry='12.34266' transform='matrix(1 0 0 1 277.37489 222.045236)' fill='rgb(1,9,23)' stroke='none' stroke-width='0'/><ellipse id='milker_1-lefteye' rx='6.15782' ry='9.958732' transform='matrix(1 0 0 1 306.900599 230.041268)' fill='rgb(0,4,11)' stroke='none' stroke-width='0'/><ellipse id='milker_1-spot1' rx='142.778541' ry='55.020633' transform='matrix(0.321773 0 0 -0.3 369.518572 302.118295)' fill=hexStringSpots stroke='none' stroke-width='0'/><ellipse id='milker_1-spot2' rx='142.778541' ry='55.020633' transform='matrix(0.321773 0 0 -0.3 483.41123 269.105915)' fill=hexStringSpots stroke='none' stroke-width='0'/><ellipse id='milker_1-spot3' rx='142.778541' ry='55.020633' transform='matrix(0.321773 0 0 -0.3 475.433339 354.883081)' fill=hexStringSpots stroke='none' stroke-width='0'/><ellipse id='milker_1-ellipse1' rx='4.683021' ry='8.253095' transform='matrix(1 0 0 1 282.422685 277.35901)' fill='rgb(1,6,16)' stroke='none' stroke-width='0'/><ellipse id='milker_1-ellipse2' rx='4.683021' ry='8.253095' transform='matrix(1 0 0 1 258.422685 271.35901)' fill='rgb(1,6,16)' stroke='none' stroke-width='0'/></svg>"));

    return importSVG;
        
    }
   
    // From: https://stackoverflow.com/a/65707309/11969592
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // You could also just upload the raw SVG and have solildity convert it!
    function svgToImageURI(string memory svg) public pure returns (string memory) {
        // example:
        // <svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0,L75,200,L225,200,Z'></path></svg>
        // data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nNTAwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI4NSAzNTAnIGZpbGw9J25vbmUnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHBhdGggZmlsbD0nYmxhY2snIGQ9J00xNTAsMCxMNzUsMjAwLEwyMjUsMjAwLFonPjwvcGF0aD48L3N2Zz4=
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    function formatTokenURI(string memory imageURI) public pure returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Herd NFT", // You can add whatever name here
                                '", "description":"An NFT based on a Cow SVG!", "attributes":"", "image":"',imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }

    // remove later:
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
