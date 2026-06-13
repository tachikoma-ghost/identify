import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AuthParams = {
    'jwt' : {
      'clientId' : string,
      'authorizationUrl' : string,
      'tokenUrl' : [] | [string],
      'redirectUri' : string,
      'scope' : string,
      'preFetch' : boolean,
      'authority' : string,
      'fedCMConfigUrl' : [] | [string],
      'keysUrl' : string,
      'responseType' : string,
      'clientSecret' : [] | [string],
    }
  } |
  {
    'pkce' : {
      'userInfoEndpoint' : string,
      'clientId' : string,
      'authorizationUrl' : string,
      'tokenUrl' : string,
      'redirectUri' : string,
      'scope' : string,
      'clientSecret' : [] | [string],
    }
  };
export interface AuthResponse {
  'kind' : string,
  'delegations' : Array<Delegation>,
  'authnMethod' : string,
  'userPublicKey' : Uint8Array | number[],
}
export interface Delegation {
  'signature' : Uint8Array | number[],
  'delegation' : {
    'pubkey' : Uint8Array | number[],
    'targets' : [] | [Array<Principal>],
    'expiration' : bigint,
  },
}
export interface FrontendOAuth2Config {
  'provider' : ProviderKey,
  'auth' : AuthParams,
  'name' : string,
}
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpRequestResult {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface Main {
  /**
   * / Add a provider to the list of configured providers.
   * / If a authority is provided, the configuration will be loaded from the configuration in GET <authority>.well-known/openid-configuration.
   * / Parameters:
   * / - config: The Identify state.
   * / - provider: The provider configuration to add. If the auth field contains a authority, the configuration will be fetched from there.
   * / - caller: The principal of the caller. Must be the owner.
   */
  'addProvider' : ActorMethod<[string, AuthParams], Result>,
  /**
   * / Get cycle balance of the backend canister
   */
  'getBalance' : ActorMethod<[], { 'val' : bigint, 'text' : string }>,
  /**
   * / Get the previously prepared delegation
   */
  'getDelegation' : ActorMethod<
    [ProviderKey, string, Uint8Array | number[], Time, [] | [Array<Principal>]],
    Result__1
  >,
  /**
   * / Get an email address for a principal
   * / This function can only be called from whitelisted principals, usually the backend canister of an app
   */
  'getEmail' : ActorMethod<[Principal, string], [] | [string]>,
  /**
   * / Get principal and some user info of the caller
   */
  'getPrincipal' : ActorMethod<[], Principal>,
  /**
   * / Get the list of provider configurations for the frontend
   */
  'getProviders' : ActorMethod<[], Array<FrontendOAuth2Config>>,
  /**
   * / Get information about the app
   */
  'getStats' : ActorMethod<
    [],
    { 'loginCount' : bigint, 'appCount' : bigint, 'keyCount' : bigint }
  >,
  /**
   * / Get an email address for a principal
   * / This function can only be called from whitelisted principals, usually the backend canister of an app
   */
  'getUser' : ActorMethod<[Principal, string], [] | [User]>,
  /**
   * / Connect code and session key
   * / The codeHash is a sha256 hash of the authorization code returned from the provider
   * / By committing to the code in advance, it prevents potential attackers (boundary nodes or node machines) from intercepting the code and creating a delegation for a different sessionKey.
   */
  'lockPKCEJWTcode' : ActorMethod<
    [ProviderKey, Uint8Array | number[], Uint8Array | number[]],
    Result
  >,
  /**
   * / Verify the JWT token and prepare a delegation.
   * / The delegation can be fetched using an query call to getDelegation.
   */
  'prepareDelegation' : ActorMethod<
    [
      ProviderKey,
      string,
      string,
      Uint8Array | number[],
      bigint,
      [] | [Array<Principal>],
    ],
    PrepRes
  >,
  /**
   * / Check PKCE sign in and prepare delegation
   * /
   * / Warning:
   * / This function uses non-replicated http-outcalls to complete the authentication flow and request user data.
   * / It therefore requires some trust in the node provider, not to manipulate the requests.
   * / If possible use `prepareDelegation` instead.
   */
  'prepareDelegationPKCE' : ActorMethod<
    [
      ProviderKey,
      string,
      string,
      string,
      Uint8Array | number[],
      bigint,
      [] | [Array<Principal>],
    ],
    PrepRes
  >,
  /**
   * / Complete PKCE sign to get a JWT and prepare delegation.
   * /
   * / Warning:
   * / This function uses non-replicated http-outcalls to complete authentication.
   * / It therefore requires some trust in the node provider, not to manipulate the requests.
   * / If possible use `prepareDelegation` instead.
   */
  'prepareDelegationPKCEJWT' : ActorMethod<
    [
      ProviderKey,
      string,
      string,
      Uint8Array | number[],
      bigint,
      [] | [Array<Principal>],
    ],
    PrepRes
  >,
  /**
   * / Transform http request without changing anything
   */
  'transform' : ActorMethod<[TransformArgs], TransformResult>,
  /**
   * / Transform http request by sorting keys by key ID
   */
  'transformKeys' : ActorMethod<[TransformArgs], TransformResult>,
}
export type PrepRes = {
    'ok' : {
      'pubKey' : Uint8Array | number[],
      'expireAt' : Time,
      'isNew' : boolean,
    }
  } |
  { 'err' : string };
export type ProviderKey = string;
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result__1 = { 'ok' : { 'auth' : AuthResponse } } |
  { 'err' : string };
export type Time = bigint;
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpRequestResult,
}
export interface TransformResult {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface User {
  'id' : string,
  'bio' : [] | [string],
  'verified' : [] | [boolean],
  'username' : [] | [string],
  'provider' : ProviderKey,
  'provider_created_at' : [] | [string],
  'avatar_url' : [] | [string],
  'name' : [] | [string],
  'createdAt' : Time,
  'origin' : string,
  'following_count' : [] | [bigint],
  'public_gists' : [] | [bigint],
  'email' : [] | [string],
  'website' : [] | [string],
  'tweet_count' : [] | [bigint],
  'public_repos' : [] | [bigint],
  'email_verified' : [] | [boolean],
  'followers_count' : [] | [bigint],
  'location' : [] | [string],
}
export interface _SERVICE extends Main {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
