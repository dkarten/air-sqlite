/**
 * Created by dylankarten on 6/8/15.
 */
package com.probertson.data.sqlRunnerClasses {

import flash.data.SQLCollationType;
import flash.data.SQLConnection;
import flash.data.SQLSchemaResult;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;

public class PendingSchema {

    public function PendingSchema(type:Class, name:String,database:String,includeColumnSchema:Boolean, handler:Function, errorHandler:Function) {
        _type = type;
        _name = name;
        _database = database;
        _columnSchema = includeColumnSchema;
        _handler = handler;
        _errorHandler = errorHandler;
    }


    // ------- Member vars -------

    private var _type:Class;
    private var _name:String;
    private var _database:String;
    private var _columnSchema:Boolean;
    private var _handler:Function;
    private var _errorHandler:Function;
    private var _pool:ConnectionPool;

    // ------- Public methods -------

    public function executeWithConnection(pool:ConnectionPool, conn:SQLConnection):void
    {
        _pool = pool;

        conn.addEventListener(SQLEvent.SCHEMA, schema_result);
        conn.addEventListener(SQLErrorEvent.ERROR, schema_error);
        conn.loadSchema(_type, _name, _database, _columnSchema);
    }


    // ------- Event handling -------

    private function schema_result(event:SQLEvent):void
    {
        var conn:SQLConnection = event.currentTarget as SQLConnection;
        conn.removeEventListener(SQLEvent.RESULT, schema_result);
        conn.removeEventListener(SQLErrorEvent.ERROR, schema_error);
        var result:SQLSchemaResult = conn.getSchemaResult();
        _pool.returnConnection(conn);

        if (_handler != null)
            _handler(result);
    }


    private function schema_error(event:SQLErrorEvent):void
    {
        var conn:SQLConnection = event.currentTarget as SQLConnection;
        conn.removeEventListener(SQLEvent.RESULT, schema_result);
        conn.removeEventListener(SQLErrorEvent.ERROR, schema_error);
        _pool.returnConnection(conn);
        if (_errorHandler != null)
            _errorHandler(event.error);
    }
}
}
