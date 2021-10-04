pragma solidity >= 0.8.7;

// the location of the pixel is used as an identifier because the location can't change and will always be unique

/*

a pixel is defined as:
- location data
- color data
- owner data

*/

/*

we need:
- a mapping of wallets to pixels (w->p)
- a mapping of pixel locations (uint24) to colors (uint32), with a bit at the beginning denoting whether the pixel is owned or not, 1 for owned, 0 for not owned (p->c)
    - example of a color value in binary: 00000001111111111111111111111111
                                                 ^ this bit is "1" if the pixel is owned, "0" if it is not, the rest is the rgb color value

when a user tries buying a pixel:
- parameters will be color (uint24) and location (uint24)
1. make sure the pixels location is less than 1,000,000 (as the grid is 1000x1000 and counting starts at 0)
2. make sure the pixel isn't ownder by looking in p->c for the pixel trying to be bought and see if the bit denoting ownership is 1 or 0
3. add the pixel to the senders wallet (w->p)
4. set the color (p->c) to the senders defined color and add (1 << 24) to denote ownership

when a user wants to transfer a pixel:
- parameters will be the receiving address and location (uint24)
1. make sure the senders address isn't the same as the receivers address
1. make sure that the pixel is owned by the sender by checking their wallet (w->p)
4. remove the pixel from the senders wallet (w->p)
5. add the pixel to the receivers wallet (w-p)


when a user wants to change the color of a pixel:
- parameters will be color (uint24) and location (uint24)
1. make sure that the pixel is owned by the sender by checking their wallet (w->p)
4. set the color (p->c) to the senders defined color and add (1 << 24) to denote ownership

*/


contract Image {
    mapping(address => mapping(uint24 => bool)) public wallets; // wallet address => list of uint24's where each uint24 is the location of a pixel => true of false whether pixel is owned or not
    mapping(uint24 => uint32) public pixels; // pixels location => color and meta data
    
    function buyPixel(uint24 color, uint24 location) public {
        require(location < 1000000);
        require((pixels[location] >> 24) == 0);
        wallets[msg.sender][location] = true;
        pixels[location] = (1 << 24) + color;
    }
    
    function transferPixel(address receiving_address, uint24 location) public {
        require(msg.sender != receiving_address);
        require(wallets[msg.sender][location] == true);
        wallets[msg.sender][location] = false;
        wallets[receiving_address][location] = true;
    }
    
    function changeColor(uint24 color, uint24 location) public {
        require(wallets[msg.sender][location] == true);
        pixels[location] = (1 << 24) + color;
    }
}
