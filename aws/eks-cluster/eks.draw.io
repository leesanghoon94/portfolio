<?xml version="1.0" encoding="UTF-8"?>
<mxfile>
  <diagram id="AWS-EKS-Architecture" name="Page-1">
    <mxGraphModel>
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        
        <!-- VPC -->
        <mxCell id="vpc" value="VPC" style="rounded=1;fillColor=#D6EAF8;strokeColor=#2980B9;" vertex="1" parent="1">
          <mxGeometry x="100" y="100" width="800" height="500" as="geometry" />
        </mxCell>
        
        <!-- Public Subnet -->
        <mxCell id="public_subnet" value="Public Subnet" style="rounded=1;fillColor=#ABEBC6;strokeColor=#239B56;" vertex="1" parent="vpc">
          <mxGeometry x="120" y="150" width="350" height="180" as="geometry" />
        </mxCell>
        
        <!-- Private Subnet -->
        <mxCell id="private_subnet" value="Private Subnet" style="rounded=1;fillColor=#F9E79F;strokeColor=#D4AC0D;" vertex="1" parent="vpc">
          <mxGeometry x="500" y="150" width="350" height="180" as="geometry" />
        </mxCell>
        
        <!-- EKS Cluster -->
        <mxCell id="eks_cluster" value="EKS Cluster" style="rounded=1;fillColor=#D5DBDB;strokeColor=#7B7D7D;" vertex="1" parent="private_subnet">
          <mxGeometry x="550" y="200" width="250" height="100" as="geometry" />
        </mxCell>
        
        <!-- Karpenter -->
        <mxCell id="karpenter" value="Karpenter (Auto-Scaling)" style="rounded=1;fillColor=#F5B7B1;strokeColor=#C0392B;" vertex="1" parent="eks_cluster">
          <mxGeometry x="600" y="250" width="150" height="50" as="geometry" />
        </mxCell>
        
        <!-- AWS Load Balancer Controller -->
        <mxCell id="alb_controller" value="AWS Load Balancer Controller" style="rounded=1;fillColor=#AED6F1;strokeColor=#2471A3;" vertex="1" parent="eks_cluster">
          <mxGeometry x="600" y="300" width="200" height="50" as="geometry" />
        </mxCell>
        
        <!-- FluentBit -->
        <mxCell id="fluentbit" value="FluentBit (Logging)" style="rounded=1;fillColor=#D2B4DE;strokeColor=#8E44AD;" vertex="1" parent="eks_cluster">
          <mxGeometry x="600" y="350" width="150" height="50" as="geometry" />
        </mxCell>
        
        <!-- Prometheus -->
        <mxCell id="prometheus" value="Prometheus (Monitoring)" style="rounded=1;fillColor=#F7DC6F;strokeColor=#B7950B;" vertex="1" parent="eks_cluster">
          <mxGeometry x="600" y="400" width="150" height="50" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
