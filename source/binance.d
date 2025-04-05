module binance;

import client;

class Binance {
	
	string api_key;
	string secret_key;
	Client client;

	this(string api_key, string secret_key)
	{
		this.api_key = api_key;
		this.secret_key = secret_key;
		this.client = new Client(this);
	}
}
