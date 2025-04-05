module binance;

import client;
import general;

class Binance {
	
	string api_key;
	string secret_key;
	Client client;
	General general;
	
	this(string api_key, string secret_key)
	{
		this.api_key = api_key;
		this.secret_key = secret_key;
		this.client = new Client(this);
		this.general = new General(this);
	}
}
