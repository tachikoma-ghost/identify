export const idlFactory = ({ IDL }) => {
  const AuthParams = IDL.Variant({
    'jwt' : IDL.Record({
      'clientId' : IDL.Text,
      'authorizationUrl' : IDL.Text,
      'tokenUrl' : IDL.Opt(IDL.Text),
      'redirectUri' : IDL.Text,
      'scope' : IDL.Text,
      'preFetch' : IDL.Bool,
      'authority' : IDL.Text,
      'fedCMConfigUrl' : IDL.Opt(IDL.Text),
      'keysUrl' : IDL.Text,
      'responseType' : IDL.Text,
      'clientSecret' : IDL.Opt(IDL.Text),
    }),
    'pkce' : IDL.Record({
      'userInfoEndpoint' : IDL.Text,
      'clientId' : IDL.Text,
      'authorizationUrl' : IDL.Text,
      'tokenUrl' : IDL.Text,
      'redirectUri' : IDL.Text,
      'scope' : IDL.Text,
      'clientSecret' : IDL.Opt(IDL.Text),
    }),
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const ProviderKey = IDL.Text;
  const Time = IDL.Int;
  const Delegation = IDL.Record({
    'signature' : IDL.Vec(IDL.Nat8),
    'delegation' : IDL.Record({
      'pubkey' : IDL.Vec(IDL.Nat8),
      'targets' : IDL.Opt(IDL.Vec(IDL.Principal)),
      'expiration' : IDL.Int,
    }),
  });
  const AuthResponse = IDL.Record({
    'kind' : IDL.Text,
    'delegations' : IDL.Vec(Delegation),
    'authnMethod' : IDL.Text,
    'userPublicKey' : IDL.Vec(IDL.Nat8),
  });
  const Result__1 = IDL.Variant({
    'ok' : IDL.Record({ 'auth' : AuthResponse }),
    'err' : IDL.Text,
  });
  const FrontendOAuth2Config = IDL.Record({
    'provider' : ProviderKey,
    'auth' : AuthParams,
    'name' : IDL.Text,
  });
  const User = IDL.Record({
    'id' : IDL.Text,
    'bio' : IDL.Opt(IDL.Text),
    'verified' : IDL.Opt(IDL.Bool),
    'username' : IDL.Opt(IDL.Text),
    'provider' : ProviderKey,
    'provider_created_at' : IDL.Opt(IDL.Text),
    'avatar_url' : IDL.Opt(IDL.Text),
    'name' : IDL.Opt(IDL.Text),
    'createdAt' : Time,
    'origin' : IDL.Text,
    'following_count' : IDL.Opt(IDL.Nat),
    'public_gists' : IDL.Opt(IDL.Nat),
    'email' : IDL.Opt(IDL.Text),
    'website' : IDL.Opt(IDL.Text),
    'tweet_count' : IDL.Opt(IDL.Nat),
    'public_repos' : IDL.Opt(IDL.Nat),
    'email_verified' : IDL.Opt(IDL.Bool),
    'followers_count' : IDL.Opt(IDL.Nat),
    'location' : IDL.Opt(IDL.Text),
  });
  const PrepRes = IDL.Variant({
    'ok' : IDL.Record({
      'pubKey' : IDL.Vec(IDL.Nat8),
      'expireAt' : Time,
      'isNew' : IDL.Bool,
    }),
    'err' : IDL.Text,
  });
  const HttpHeader = IDL.Record({ 'value' : IDL.Text, 'name' : IDL.Text });
  const HttpRequestResult = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  const TransformArgs = IDL.Record({
    'context' : IDL.Vec(IDL.Nat8),
    'response' : HttpRequestResult,
  });
  const TransformResult = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  const Main = IDL.Service({
    'addProvider' : IDL.Func([IDL.Text, AuthParams], [Result], []),
    'getBalance' : IDL.Func(
        [],
        [IDL.Record({ 'val' : IDL.Nat, 'text' : IDL.Text })],
        ['query'],
      ),
    'getDelegation' : IDL.Func(
        [
          ProviderKey,
          IDL.Text,
          IDL.Vec(IDL.Nat8),
          Time,
          IDL.Opt(IDL.Vec(IDL.Principal)),
        ],
        [Result__1],
        ['query'],
      ),
    'getEmail' : IDL.Func(
        [IDL.Principal, IDL.Text],
        [IDL.Opt(IDL.Text)],
        ['query'],
      ),
    'getPrincipal' : IDL.Func([], [IDL.Principal], ['query']),
    'getProviders' : IDL.Func([], [IDL.Vec(FrontendOAuth2Config)], ['query']),
    'getStats' : IDL.Func(
        [],
        [
          IDL.Record({
            'loginCount' : IDL.Nat,
            'appCount' : IDL.Nat,
            'keyCount' : IDL.Nat,
          }),
        ],
        ['query'],
      ),
    'getUser' : IDL.Func([IDL.Principal, IDL.Text], [IDL.Opt(User)], ['query']),
    'lockPKCEJWTcode' : IDL.Func(
        [ProviderKey, IDL.Vec(IDL.Nat8), IDL.Vec(IDL.Nat8)],
        [Result],
        [],
      ),
    'prepareDelegation' : IDL.Func(
        [
          ProviderKey,
          IDL.Text,
          IDL.Text,
          IDL.Vec(IDL.Nat8),
          IDL.Nat,
          IDL.Opt(IDL.Vec(IDL.Principal)),
        ],
        [PrepRes],
        [],
      ),
    'prepareDelegationPKCE' : IDL.Func(
        [
          ProviderKey,
          IDL.Text,
          IDL.Text,
          IDL.Text,
          IDL.Vec(IDL.Nat8),
          IDL.Nat,
          IDL.Opt(IDL.Vec(IDL.Principal)),
        ],
        [PrepRes],
        [],
      ),
    'prepareDelegationPKCEJWT' : IDL.Func(
        [
          ProviderKey,
          IDL.Text,
          IDL.Text,
          IDL.Vec(IDL.Nat8),
          IDL.Nat,
          IDL.Opt(IDL.Vec(IDL.Principal)),
        ],
        [PrepRes],
        [],
      ),
    'transform' : IDL.Func([TransformArgs], [TransformResult], ['query']),
    'transformKeys' : IDL.Func([TransformArgs], [TransformResult], ['query']),
  });
  return Main;
};
export const init = ({ IDL }) => { return []; };
