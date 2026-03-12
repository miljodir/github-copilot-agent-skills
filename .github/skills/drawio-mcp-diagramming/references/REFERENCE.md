# Draw.io Azure2 & AWS4 References

This folder contains reference artifacts for the `drawio-mcp-diagramming` skill.

## Files

- `azure2-complete-catalog.txt`
  - Complete Azure2 icon inventory (648 icons) from `jgraph/drawio` GitHub tree under `img/lib/azure2`.
  - Use this as the canonical lookup for Azure icon paths — **no scripts needed at agent runtime**.
  - Agent usage: `grep -i "keyword" references/azure2-complete-catalog.txt`

- `aws4-complete-catalog.txt`
  - Complete AWS4 stencil shape inventory (1,037 shapes) extracted from `jgraph/drawio` stencil XML.
  - **AWS4 icons are stencil-based** — referenced as `shape=mxgraph.aws4.<name>`, not as SVG files.
  - Each line in the catalog is a ready-to-use `shape=mxgraph.aws4.*` style string.
  - Agent usage: `grep -i "keyword" references/aws4-complete-catalog.txt`
  - Generate/refresh with: `python3 scripts/search_aws4_icons_github.py --max-results 9999 > references/aws4-complete-catalog.txt`

- `layout-antipatterns.md`
  - Worked examples of layout problems (stacked edges, repeated labels, observability inside VNet/VPC, etc.)
  - Derived from real diagram review sessions.
  - Use this as the first reference when a diagram looks cluttered or has overlapping lines/labels.

## Refresh Workflow

Refresh the catalogs when draw.io updates its icon library (not required per-run):

### Azure2 Catalog

```bash
cd .github/skills/drawio-mcp-diagramming/scripts
python3 search_azure2_icons_github.py --max-results 9999 > ../references/azure2-complete-catalog.txt
```

### AWS4 Catalog

```bash
cd .github/skills/drawio-mcp-diagramming/scripts
python3 search_aws4_icons_github.py --max-results 9999 > ../references/aws4-complete-catalog.txt
```

## Notes

- The catalogs are pre-generated — agents should grep them directly rather than running scripts.
- If an icon appears missing from a catalog, re-run the relevant refresh workflow above.
- If render review shows bad/missing icons, grep the catalog for alternative paths and substitute.

## Example Prompt Templates

### Azure Network Topology Diagram (Infrastructure Focus)

```text
Create a professional Azure network topology diagram from my Terraform infrastructure
in the components/ folder, emphasizing network isolation and traffic flows.

Requirements:
- Show VNet architecture with clear network boundaries (use thick borders strokeWidth=4
  for VNets, dashed borders strokeWidth=2 dashPattern=8 8 for subnets)
- Position all resources (VMs, databases, load balancers, etc.) inside their
  respective subnets to show network isolation
- Label all traffic flows with protocols and ports (e.g., HTTPS:443,
  PostgreSQL:5432, HTTP:8080)
- Include a traffic legend showing different traffic types with color-coded arrows
- Add a network isolation explanation box showing the visual conventions
- Use a larger canvas (1900x1500) to accommodate the multi-VNet topology
- Color-code different zones (DMZ VNet in yellow, Internal VNet in green,
  Management zone in blue, VNet Peering in grey, External Services in orange)
- Show VNet peering connections and external services in separate zones
- Use Azure2 icons from draw.io MCP

Focus on the networking aspects - how components are isolated, how traffic flows
between them, and what the network boundaries are.
```

### Basic Azure Architecture Diagram

```text
Use drawio/create_diagram to generate a hub-spoke Azure architecture diagram.
Use Azure2 image styles (image=img/lib/azure2/...) for all Azure resources.
Include [list services] and show ingress/egress/telemetry flows.
```

### AWS Network Topology Diagram (Infrastructure Focus)

```text
Create a professional AWS network topology diagram emphasising VPC design,
subnet tiers, and traffic flows.

Requirements:
- Show VPC architecture with clear network boundaries (use thick borders strokeWidth=4
  for VPCs, dashed borders strokeWidth=2 dashPattern=8 8 for subnets)
- Group subnets by Availability Zone using light grey AZ containers
- Colour-code subnet tiers: public (light green), private (light blue),
  isolated/database (light orange)
- Position all resources (EC2, RDS, Lambda, ALB, etc.) inside their respective subnets
- Show Internet Gateway and NAT Gateway for public/private subnet egress
- Label all traffic flows with protocols and ports (e.g., HTTPS:443,
  PostgreSQL:5432, SSH:22)
- Include a traffic legend showing different traffic types with colour-coded arrows
- Add a network isolation explanation box (VPC thick borders, subnet dashed borders,
  SG/NACL annotations, VPC Endpoints for private AWS service access)
- Use a larger canvas (1900x1500) for multi-VPC/multi-account topologies
- Separate internet/edge services zone (CloudFront, Route53, WAF, Shield)
  and VPC Peering / Transit Gateway zone
- Use AWS4 icons from draw.io MCP

Focus on the networking aspects - VPC isolation boundaries, AZ redundancy,
traffic routing, and security controls.
```

### Basic AWS Architecture Diagram

```text
Use drawio/create_diagram to generate a 3-tier AWS architecture diagram.
Use AWS4 image styles (image=img/lib/aws4/...) for all AWS resources.
Include [list services] and show ingress/egress/data flows.
```

### Multi-Cloud (Azure + AWS) Architecture Diagram

```text
Use drawio/create_diagram to generate a multi-cloud architecture diagram
showing both Azure and AWS components connected via [VPN/ExpressRoute/Direct Connect].

Use Azure2 image styles (image=img/lib/azure2/...) for Azure resources.
Use AWS4 image styles (image=img/lib/aws4/...) for AWS resources.
Show connectivity, data replication, and identity federation between the clouds.
```