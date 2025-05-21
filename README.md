# Wolf Marketplace API

## API Endpoints

### Authentication

#### Client Authentication

- `POST /api/client/login`
  - Creates a new client session
  - Returns a JWT token for authentication
  - Required params: `email`, `password`
- `DELETE /api/client/logout`
  - Destroys the current client session
  - Requires authentication

#### Job Seeker Authentication

- `POST /api/job-seeker/login`
  - Creates a new job seeker session
  - Returns a JWT token for authentication
  - Required params: `email`, `password`
- `DELETE /api/job-seeker/logout`
  - Destroys the current job seeker session
  - Requires authentication

### Opportunities

#### List Opportunities

- `GET /api/opportunities`
  - Returns a paginated list of opportunities
  - Optional query params:
    - `query`: Search term for filtering opportunities
    - `page`: Page number (default: 1)
    - `per_page`: Items per page (default: 10)
  - Returns:
    - List of opportunities with client details
    - Pagination metadata (current_page, total_pages, total_count)

#### Create Opportunity

- `POST /api/opportunities`
  - Creates a new opportunity
  - Requires client authentication
  - Required params:
    - `title`: Job title
    - `description`: Job description
    - `salary`: Salary amount
  - Returns the created opportunity

#### Apply for Opportunity

- `POST /api/opportunities/:id/apply`
  - Creates a job application
  - Requires job seeker authentication
  - Returns the created application
  - Duplicate applications are rejected

## Search Functionality

The opportunity search is implemented using PostgreSQL's ILIKE operator with GIN indices for optimal performance. The search:

1. **Search Fields**:

   - Opportunity title
   - Opportunity description
   - Client name

2. **Search Behavior**:

   - Case-insensitive matching
   - Partial word matching
   - Matches any of the search fields

3. **Performance Optimization**:
   - Uses GIN indices with trigram support
   - Indices are created on:
     - `opportunities.title`
     - `opportunities.description`
     - `clients.name`

Example search queries:

```ruby
# Search by client name
GET /api/opportunities?query=Unique%20Company

# Search by partial title
GET /api/opportunities?query=Registered

# Search by description
GET /api/opportunities?query=experienced
```

## Caching Strategy

The opportunity search results are cached to improve performance. The caching implementation:

1. **Cache Configuration**:

   - Cache duration: 1 hour
   - Cache store: Redis
   - Disabled in development

2. **Cache Keys**:

   - Format: `opportunities/{query}/page_{page}/per_{per_page}`
   - Example: `opportunities/Unique Company/page_1/per_10`

3. **Cache Invalidation**:
   The cache is invalidated when:

   - A new opportunity is created
   - An existing opportunity is updated
   - An opportunity is deleted

Example cache key generation:

```ruby
# For search query "Unique Company", page 2, 5 items per page
"opportunities/Unique Company/page_2/per_5"
```

## Development Setup

1. Install dependencies:

   ```bash
   bundle install
   ```

2. Set up the database:

   ```bash
   rails db:create db:migrate
   ```

3. Run the test suite:
   ```bash
   bundle exec rspec
   ```
   Or run the rails server:
   ```bash
   bundle exec rails server
   ```

## Production Requirements

1. **Database**:

   - Uses PostgreSQL
   - Requires the `pg_trgm` extension for search indices

2. **Caching**:

   - Requires Redis
