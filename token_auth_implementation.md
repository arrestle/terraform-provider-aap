# AAP Provider Token Authentication Implementation

## Current vs Token Authentication

### Current (Basic Auth):
```
Authorization: Basic <base64(username:password)>
```

### Token Auth:
```
Authorization: Bearer <token>
```

## Implementation Steps

### 1. Update Provider Schema

Add `token` field to provider schema in `internal/provider/provider.go`:

```go
// Add to provider schema (line ~48)
"token": schema.StringAttribute{
    Optional:  true,
    Sensitive: true,
    Description: "OAuth2 token or Personal Access Token for authentication. " +
                "Can also be set via AAP_TOKEN environment variable.",
},
```

### 2. Update Provider Model

Add token field to `aapProviderModel` struct (line ~166):

```go
type aapProviderModel struct {
    Host               types.String `tfsdk:"host"`
    Username           types.String `tfsdk:"username"`
    Password           types.String `tfsdk:"password"`
    Token              types.String `tfsdk:"token"`  // Add this
    InsecureSkipVerify types.Bool   `tfsdk:"insecure_skip_verify"`
    Timeout            types.Int64  `tfsdk:"timeout"`
}
```

### 3. Update ReadValues Method

Modify `ReadValues` method (line ~201):

```go
func (p *aapProviderModel) ReadValues(host, username, password, token *string, 
    insecureSkipVerify *bool, timeout *int64, resp *provider.ConfigureResponse) {
    
    // Set default values from env variables
    *host = os.Getenv("AAP_HOST")
    *username = os.Getenv("AAP_USERNAME")
    *password = os.Getenv("AAP_PASSWORD")
    *token = os.Getenv("AAP_TOKEN")  // Add this

    // Read from user configuration
    if !p.Host.IsNull() {
        *host = p.Host.ValueString()
    }
    if !p.Username.IsNull() {
        *username = p.Username.ValueString()
    }
    if !p.Password.IsNull() {
        *password = p.Password.ValueString()
    }
    if !p.Token.IsNull() {  // Add this
        *token = p.Token.ValueString()
    }
    
    // ... rest of method
}
```

### 4. Update Configure Method

Modify provider `Configure` method (line ~91):

```go
func (p *aapProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config aapProviderModel
    // ... existing code ...

    var host, username, password, token string  // Add token
    var insecureSkipVerify bool
    var timeout int64
    
    config.ReadValues(&host, &username, &password, &token, &insecureSkipVerify, &timeout, resp)
    
    // Validation logic - either token OR username/password required
    if len(token) == 0 {
        // Traditional auth - require username/password
        if len(host) == 0 {
            AddConfigurationAttributeError(resp, "host", "AAP_HOST", false)
        }
        if len(username) == 0 {
            AddConfigurationAttributeError(resp, "username", "AAP_USERNAME", false)
        }
        if len(password) == 0 {
            AddConfigurationAttributeError(resp, "password", "AAP_PASSWORD", false)
        }
    } else {
        // Token auth - only require host
        if len(host) == 0 {
            AddConfigurationAttributeError(resp, "host", "AAP_HOST", false)
        }
    }

    if resp.Diagnostics.HasError() {
        return
    }

    // Create client with token support
    client, diags := NewClient(host, &username, &password, &token, insecureSkipVerify, timeout)
    resp.Diagnostics.Append(diags...)
    
    // ... rest of method
}
```

### 5. Update Client Structure

Modify `AAPClient` struct in `internal/provider/client.go` (line ~31):

```go
type AAPClient struct {
    HostURL     string
    Username    *string
    Password    *string
    Token       *string  // Add this
    httpClient  *http.Client
    ApiEndpoint string
}
```

### 6. Update NewClient Function

Modify `NewClient` function (line ~83):

```go
func NewClient(host string, username, password, token *string, insecureSkipVerify bool, timeout int64) (*AAPClient, diag.Diagnostics) {
    hostURL, _ := url.JoinPath(host, "/")
    client := AAPClient{
        HostURL:  hostURL,
        Username: username,
        Password: password,
        Token:    token,  // Add this
    }
    
    // ... rest of function
}
```

### 7. Update doRequest Method

Modify authentication logic in `doRequest` (line ~125):

```go
func (c *AAPClient) doRequest(method string, path string, data io.Reader) (*http.Response, []byte, error) {
    ctx := context.Background()
    req, err := http.NewRequestWithContext(ctx, method, c.computeURLPath(path), data)
    if err != nil {
        return nil, []byte{}, err
    }
    
    // Token authentication takes precedence
    if c.Token != nil && *c.Token != "" {
        req.Header.Set("Authorization", "Bearer " + *c.Token)
    } else if c.Username != nil && c.Password != nil {
        req.SetBasicAuth(*c.Username, *c.Password)
    }

    req.Header.Set("Accept", "application/json")
    req.Header.Set("Content-Type", "application/json")

    // ... rest of method
}
```

## Usage Examples

### 1. Using OAuth2 Token in Configuration

```hcl
provider "aap" {
  host  = "https://aap-server.com"
  token = "your-oauth2-token-here"
}
```

### 2. Using Environment Variable

```bash
export AAP_HOST="https://aap-server.com"
export AAP_TOKEN="your-oauth2-token-here"

terraform apply
```

### 3. Mixed Configuration (token overrides username/password)

```hcl
provider "aap" {
  host     = "https://aap-server.com"
  username = "admin"      # Ignored when token is present
  password = "password"   # Ignored when token is present  
  token    = "oauth2-token"  # This will be used
}
```

## How to Generate Tokens in AAP

### Personal Access Token (PAT)
1. Login to AAP Web UI
2. Go to **Access Management** → **Users**
3. Select your user → **Tokens** tab
4. Click **Create Token**
5. Set scope (Read/Write) and save
6. Copy the token (only shown once!)

### OAuth2 Application Token
1. Go to **Access Management** → **OAuth Applications**
2. Create application with "Authorization Code" grant type
3. Use client credentials to get tokens via API:

```bash
curl -X POST \
  -d "grant_type=password&username=admin&password=secret" \
  -u "client_id:client_secret" \
  https://aap-server.com/o/token/
```

## Benefits of Token Authentication

1. **Security**: Tokens can be scoped and revoked independently
2. **Rotation**: Easier credential rotation without changing configs
3. **Integration**: Better for CI/CD and automation workflows  
4. **Audit**: Better tracking of API usage per application
5. **Expiration**: Tokens can have automatic expiration

## Migration Path

1. **Phase 1**: Add token support (backward compatible)
2. **Phase 2**: Update documentation with token examples
3. **Phase 3**: Deprecate username/password (future release)
4. **Phase 4**: Remove username/password support (major version)