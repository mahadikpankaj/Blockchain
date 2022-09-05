/*
SPDX-License-Identifier: Apache-2.0
*/

'use strict';
const State = require('./state.js');
const utils = require('../lib/utils/utility-functions.js');
/**
 * StateList provides a named virtual container for a set of ledger states.
 * Each state has a unique key which associates it with the container, rather
 * than the container containing a link to the state. This minimizes collisions
 * for parallel transactions on different states.
 */
class StateList {

    /**
     * Store Fabric context for subsequent API access, and name of list
     */
    constructor(ctx, listName) {
        this.ctx = ctx;
        this.name = listName;
        this.supportedClasses = {};

    }

    /**
     * Add a state to the list. Creates a new state in worldstate with
     * appropriate composite key.  Note that state defines its own key.
     * State object is serialized before writing.
     */
    async addState(state) {
        let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
        console.log("createCompositeKey addState: " + key);
        state[state.keyField] = key; //JSON.parse(JSON.stringify(key)); 
        state = utils.reorderFields(state);
        let data = State.serialize(state);
        console.log("Composite Key: " +  key);
        await this.ctx.stub.putState(key, data);
        return state;
    }

    /**
     * Get a state from the list using supplied keys. Form composite
     * keys to retrieve state from world state. State data is deserialized
     * into JSON object before being returned.
     */
     async getState(key) {
        let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));

        console.log("createCompositeKey getState: " + ledgerKey);

        let data = await this.ctx.stub.getState(ledgerKey);
        if (data) {
            let state = State.deserialize(data, this.supportedClasses);
            return state;
        } else {
            return null;
        }
    }

    async getStateByCompositeKey(ledgerKey) {

        console.log("createCompositeKey getStateByCompositeKey: " + ledgerKey);

        let data = await this.ctx.stub.getState(ledgerKey);
        if (data) {
            let state = State.deserialize(data, this.supportedClasses);
            return state;
        } else {
            return null;
        }
    }

    async getStateHistory(key) {
        let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));
        console.log("compositeKey in getStateHistory: " + ledgerKey);
		let historyIterator = await this.ctx.stub.getHistoryForKey(ledgerKey);
        let historyResults = await this.getAllResults(historyIterator, true);

		return historyResults;
    }

    async deleteState(key) {
        let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));
        console.log("createCompositeKey getState: " + ledgerKey);
        await this.ctx.stub.deleteState(ledgerKey);
    }

    /**
     * Update a state in the list. Puts the new state in world state with
     * appropriate composite key.  Note that state defines its own key.
     * A state is serialized before writing. Logic is very similar to
     * addState() but kept separate becuase it is semantically distinct.
     */
    async updateState(state) {
        let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
        console.log("createCompositeKey updateState: " + key);
        state = utils.reorderFields(state);
        let data = State.serialize(state);

        await this.ctx.stub.putState(key, data);
        return state;
    }

    async getStatesList(queryString) {
        if (queryString.length < 1) {
            throw new Error('Incorrect number of arguments. Expecting queryString');
        }
        console.log('queryString: ' + queryString);
        let iterator = await this.ctx.stub.getQueryResult(queryString);
        console.log('iterator: ' + iterator);
        let allResults = await this.getAllResults(iterator);

        return allResults;
    }

    async getAllResults(iterator, useJSON=false) {
        const allResults = [];
        while (true) {
            const res = await iterator.next();
            if (res.value) {
                let objString = res.value.value.toString('utf8');
                if(useJSON){
                    allResults.push(JSON.parse(objString));
                }else{
                    allResults.push(objString);
                }
            }

            if (res.done) {
                await iterator.close();
                return allResults;
            }
        }
    }
    /** Stores the class for future deserialization */
    use(stateClass) {
        this.supportedClasses[stateClass.getClass()] = stateClass;
    }
}

module.exports = StateList;