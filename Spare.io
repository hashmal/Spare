// Copyright (c) 2014, Jérémy Pinat. All rights reserved.

Regex
Socket

Sequence indent := method(
    self clone split("\n") map(i, "         " .. i) join("\n")
)

Spare := Server clone do(
    RequestHandler := Object clone do(
        parseRequestString := method(str,
            // Remove silly \r line endings
            str := str split("\r") join

            match := str findRegex("^\\s*$" asRegex multiline)
            firstLine := str findRegex("[^\\n]*")
            firstLine = firstLine captures at(0) split
            fullPath := firstLine at(1) split("?")

            self requestMethod := firstLine at(0)
            self scriptName := ""
            self pathInfo := fullPath at(0)
            self queryString := if(fullPath size > 1, fullPath at(1), "")
            self rawHeaders := str splitAt(match range first) at(0)
            self fullPath := firstLine at(1)
        )

        requestMethod := nil
        scriptName := nil
        pathInfo := nil
        queryString := nil
        rawHeaders := nil
        fullPath := nil

        handleApp := method(aSocket, aServer,
            str := ""
            while(str findRegex("^[\\s\\t]*$" asRegex multiline) not,
                str = aSocket read readBuffer asString
            )
            parseRequestString(str)

            // Logging
            write(
                Date clone now asString("%H:%M:%S"), " ",
                requestMethod, " ",
                fullPath, "\n"
            )

            // Build the environment object
            env := Map clone

            rawHeaders split("\n") slice(1) foreach(str,
                caps := str findRegex("([^:]+):[\\s\\t]*(.+)" asRegex) captures
                key := "HTTP_" .. caps at(1) asUppercase split("-") join("_")
                env atPut(key, caps at(2))
            )

            env atPut("REQUEST_METHOD", requestMethod)
            env atPut("SCRIPT_NAME", scriptName)
            env atPut("PATH_INFO", pathInfo)
            env atPut("QUERY_STRING", queryString)
            if(env hasKey("HTTP_HOST")) then(
                env atPut("SERVER_NAME", env at("HTTP_HOST"))
            ) else(
                env atPut("SERVER_NAME", aSocket host)
            )
            env atPut("SERVER_PORT", aServer port asString)

            // Execute application and get the results
            result := aServer app call(env)

            status  := result at(0)
            headers := result at(1)
            body    := result at(2) reduce(..)

            if(headers hasKey("Content-Length") not) then(
                headers atPut("Content-Length", body size)
            )

            // Send response
            aSocket write(list(
                "HTTP/1.1 ",
                status,
                "\n",
                headers map(k,v, k .. ": " .. v .. "\n") reduce(..),
                "\n",
                body
            ) reduce(..))
            
            // Clean up and logging
            aSocket close
            # status indent println
        )
    )

    // Must be called before starting the server.
    setApp := method(obj,
        self app := obj
        return self
    )

    // Handle requests in separate coroutines.
    handleSocket := method(aSocket,
        # TODO: catch errors
        RequestHandler clone @@handleApp(aSocket, self)
    )

    // Overridding to provide a logging message.
    start := method(
        write("Starting server on port " .. self port .. ".\n")
        super(start)
    )
)
