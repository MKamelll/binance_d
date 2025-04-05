module general;

import binance;

class General
{
    Binance bn;

    this(Binance bn)
    {
        this.bn = bn;
    }

    auto ping()
    {
        bn.client.endpoint = "/api/v3/ping";
        bn.client.method = "get";
        return this;
    }

    auto server_time()
    {
        bn.client.endpoint = "/api/v3/time";
        bn.client.method = "get";
        return this;
    }

    auto exchange_info()
    {
        bn.client.endpoint = "/api/v3/exchangeInfo";
        bn.client.method = "get";
        return this;
    }

    auto symbol(string symbol)
    {
        bn.client.add_param("symbol", symbol);
        return this;
    }

    auto symbols(string[] symbols...)
    {
        string symbols_uri = bn.client.uri_encode_list(symbols);
        bn.client.add_param("symbols", symbols_uri);
        return this;
    }

    auto permissions(string[] permissions...)
    {
        string permissions_uri = bn.client.uri_encode_list(permissions);
        bn.client.add_param("permissions", permissions_uri);
        return this;
    }

    auto perform()
    {
        return bn.client.perform();
    }
}