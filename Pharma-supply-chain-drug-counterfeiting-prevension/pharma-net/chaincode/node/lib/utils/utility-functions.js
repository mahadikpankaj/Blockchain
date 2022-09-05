'use strict';
const crypto = require('crypto');
//const companyTypes = new Set(['MANUFACTURER', 'DISTRIBUTOR', 'RETAILER', 'TRANSPORTER', 'CONSUMER']);
const companyTypes = new Set(['MANUFACTURER', 'DISTRIBUTOR', 'RETAILER', 'TRANSPORTER']);

class UtilityFunctions {
    
    //function to remove spaces and convert the input into upper case
    static formatKey(inputStr) {
        console.log("inside formatKey() with: " + inputStr );
        return this.removeSpaces(inputStr).toUpperCase();
    }

    //function to format the name input
    static formatName(inputStr) {
        return this.keepSingleSpace(inputStr);
    }

    // remove all spaces from the input
    static removeSpaces(inputStr) {
        console.log("inside removeSpaces() with: " + inputStr );
        return inputStr.toString().replace(/\s+/g, '');
    }

    //Keep exactly one space between words by removing extra spaces
    static keepSingleSpace(inputStr) {
        return inputStr.toString().trim().replace(/\s+/g, ' ');
    }

    static generateCRN(inputStr) {
        return crypto.createHash('sha1').update(inputStr, 'binary').digest('hex').substring(0, 5).toUpperCase();
    }

    static isRegisteredType(companyType) {
        return companyTypes.has(companyType.toUpperCase());
    }

    static reorderFields(o) {
        return Object.keys(o).sort().reduce((r, k) => (r[k] = o[k], r), {});
    }
    
}

module.exports=UtilityFunctions;