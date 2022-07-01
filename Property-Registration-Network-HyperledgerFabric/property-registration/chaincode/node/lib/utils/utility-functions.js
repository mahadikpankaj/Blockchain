'use strict';

class UtilityFunctions {
    //function to remove spaces and convert the input into upper case
    static formatKey(inputStr) {
        return this.removeSpaces(inputStr).toUpperCase();
    }

    //function to format the name input
    static formatName(inputStr) {
        return this.keepSingleSpace(inputStr);
    }

    // remove all spaces from the input
    static removeSpaces(inputStr) {
        return inputStr.toString().replace(/\s+/g, '');
    }

    //Keep exactly one space between words by removing extra spaces
    static keepSingleSpace(inputStr) {
        return inputStr.toString().trim().replace(/\s+/g, ' ');
    }
}

module.exports=UtilityFunctions;