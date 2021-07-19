/*
Copyright (c) 2013, iRacing.com Motorsport Simulations, LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of iRacing.com Motorsport Simulations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <string.h>

enum yaml_state {
	space,
	key,
	keysep,
	value,
	newline
};

// super simple YAML parser
bool parseYaml(const char *data, const char* path, const char **val, int *len)
{
	if(data && path && val && len)
	{
		// make sure we set this to something
		*val = NULL;
		*len = 0;

		int depth = 0;
		yaml_state state = space;

		const char *keystr = NULL;
		int keylen = 0;

		const char *valuestr = NULL;
		int valuelen = 0;

		const char *pathptr = path;
		int pathdepth = 0;

		while(*data)
		{
			switch(*data)
			{
			case ' ':
				if(state == newline)
					state = space;
				if(state == space)
					depth++;
				else if(state == key)
					keylen++;
				else if(state == value)
					valuelen++;
				break;
			case '-':
				if(state == newline)
					state = space;
				if(state == space)
					depth++;
				else if(state == key)
					keylen++;
				else if(state == value)
					valuelen++;
				else if(state == keysep)
				{
					state = value;
					valuestr = data;
					valuelen = 1;
				}
				break;
			case ':':
				if(state == key)
				{
					state = keysep;
					keylen++;
				}
				else if(state == keysep)
				{
					state = value;
					valuestr = data;
				}
				else if(state == value)
					valuelen++;
				break;
			case '\n':
			case '\r':
				if(state != newline)
				{
					if(depth < pathdepth)
					{
						return false;
					}
					else if(keylen && 0 == strncmp(keystr, pathptr, keylen))
					{
						bool found = true;
						//do we need to test the value?
						if(*(pathptr+keylen) == '{')
						{
							//search for closing brace
							int pathvaluelen = keylen + 1; 
							while(*(pathptr+pathvaluelen) && *(pathptr+pathvaluelen) != '}')
								pathvaluelen++; 

							if(valuelen == pathvaluelen - (keylen+1) && 0 == strncmp(valuestr, (pathptr+keylen+1), valuelen))
								pathptr += valuelen + 2;
							else
								found = false;
						}

						if(found)
						{
							pathptr += keylen;
							pathdepth = depth;

							if(*pathptr == '\0')
							{
								*val = valuestr;
								*len = valuelen;
								return true;
							}
						}
					}

					depth = 0;
					keylen = 0;
					valuelen = 0;
				}
				state = newline;
				break;
			default:
				if(state == space || state == newline)
				{
					state = key;
					keystr = data;
					keylen = 0; //redundant?
				}
				else if(state == keysep)
				{
					state = value;
					valuestr = data;
					valuelen = 0; //redundant?
				}
				if(state == key)
					keylen++;
				if(state == value)
					valuelen++;
				break;
			}

			// important, increment our pointer
			data++;
		}

	}
	return false;
}

