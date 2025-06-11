#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
#
# ─────────────────────────────────────────────────────────────────────────────
# Licensing:
# -----------
#                                 
#                                                                             
#   Licensed under the BSD 3-Clause License or a Commercial License.          
#   You may use this file under the terms of either license as specified in: 
#                                                                             
#      - BSD 3-Clause License (see ./LICENSE)                           
#      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
#                                                                             
#   Redistribution and use in source and binary forms, with or without       
#   modification, are permitted under the BSD license provided that the      
#   following conditions are met:                                            
#                                                                             
#     * Redistributions of source code must retain the above copyright       
#       notice, this list of conditions and the following disclaimer.       
#     * Redistributions in binary form must reproduce the above copyright    
#       notice, this list of conditions and the following disclaimer in the  
#       documentation and/or other materials provided with the distribution. 
#     * Neither the name of the project nor the names of its contributors    
#       may be used to endorse or promote products derived from this         
#       software without specific prior written permission.                  
#                                                                             
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
#   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
#   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
#   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
#
# By using this software, you agree to be bound by the terms of either license.
#
# Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
#
# ─────────────────────────────────────────────────────────────────────────────
# Contributor Guidelines:
# ------------------------
# Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
# All contributors must certify that they have the right to submit the code and agree to
# release it under the above license terms.
#
# Contributions must:
#   - Be original or appropriately attributed
#   - Include clear documentation and test cases where applicable
#   - Respect the coding and security guidelines defined in CONTRIBUTING.md
#
# ─────────────────────────────────────────────────────────────────────────────
# Terms of Use and Disclaimer:
# -----------------------------
# This software is provided "as is", without any express or implied warranty.
# In no event shall the authors, contributors, or copyright holders
# be held liable for any damages arising from the use of this software.
#
# Use of this software in critical systems (e.g., medical, nuclear, safety)
# is entirely at your own risk unless specifically licensed for such purposes.
#
# ─────────────────────────────────────────────────────────────────────────────

"""
SAGE OS CVE Binary Scanner
Integrates with Intel's cve-bin-tool to scan for vulnerabilities in built binaries
"""

import os
import sys
import subprocess
import json
import argparse
from pathlib import Path
from typing import List, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CVEScanner:
    """CVE vulnerability scanner for SAGE OS binaries"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.build_dir = self.project_root / "build"
        self.reports_dir = self.project_root / "security_reports"
        self.reports_dir.mkdir(exist_ok=True)
        
    def find_binaries(self) -> List[Path]:
        """Find all binary files in build directories"""
        binaries = []
        
        if not self.build_dir.exists():
            logger.warning(f"Build directory {self.build_dir} does not exist")
            return binaries
            
        # Find ELF files and kernel images
        for pattern in ["*.elf", "*.img", "*.bin"]:
            binaries.extend(self.build_dir.rglob(pattern))
            
        logger.info(f"Found {len(binaries)} binary files to scan")
        return binaries
        
    def scan_binary(self, binary_path: Path) -> Dict[str, Any]:
        """Scan a single binary for CVEs"""
        logger.info(f"Scanning {binary_path}")
        
        # Create output file for this binary
        output_file = self.reports_dir / f"{binary_path.stem}_cve_report.json"
        
        try:
            # Run cve-bin-tool
            cmd = [
                "cve-bin-tool",
                "--format", "json",
                "--output-file", str(output_file),
                str(binary_path)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                logger.info(f"Successfully scanned {binary_path}")
                
                # Load and return the results
                if output_file.exists():
                    with open(output_file, 'r') as f:
                        return json.load(f)
                        
            else:
                logger.error(f"CVE scan failed for {binary_path}: {result.stderr}")
                
        except subprocess.TimeoutExpired:
            logger.error(f"CVE scan timed out for {binary_path}")
        except Exception as e:
            logger.error(f"Error scanning {binary_path}: {e}")
            
        return {}
        
    def scan_docker_images(self) -> Dict[str, Any]:
        """Scan Docker images for vulnerabilities"""
        logger.info("Scanning Docker images for vulnerabilities")
        
        # Find Dockerfiles
        dockerfiles = list(self.project_root.glob("Dockerfile.*"))
        results = {}
        
        for dockerfile in dockerfiles:
            arch = dockerfile.suffix[1:]  # Remove the dot
            image_name = f"sage-os-{arch}"
            
            logger.info(f"Scanning Docker image for {arch}")
            
            try:
                # Build the image first
                build_cmd = ["docker", "build", "-f", str(dockerfile), "-t", image_name, "."]
                build_result = subprocess.run(build_cmd, cwd=self.project_root, 
                                            capture_output=True, text=True, timeout=600)
                
                if build_result.returncode != 0:
                    logger.error(f"Failed to build Docker image {image_name}: {build_result.stderr}")
                    continue
                    
                # Scan the image
                output_file = self.reports_dir / f"docker_{arch}_cve_report.json"
                scan_cmd = [
                    "cve-bin-tool",
                    "--format", "json",
                    "--output-file", str(output_file),
                    "--docker", image_name
                ]
                
                scan_result = subprocess.run(scan_cmd, capture_output=True, text=True, timeout=600)
                
                if scan_result.returncode == 0 and output_file.exists():
                    with open(output_file, 'r') as f:
                        results[arch] = json.load(f)
                        
            except subprocess.TimeoutExpired:
                logger.error(f"Docker scan timed out for {arch}")
            except Exception as e:
                logger.error(f"Error scanning Docker image {arch}: {e}")
                
        return results
        
    def generate_summary_report(self, binary_results: List[Dict], docker_results: Dict) -> None:
        """Generate a comprehensive summary report"""
        summary = {
            "scan_timestamp": subprocess.check_output(["date", "-Iseconds"]).decode().strip(),
            "project": "SAGE OS",
            "binary_scans": len(binary_results),
            "docker_scans": len(docker_results),
            "total_vulnerabilities": 0,
            "high_severity": 0,
            "medium_severity": 0,
            "low_severity": 0,
            "details": {
                "binaries": binary_results,
                "docker_images": docker_results
            }
        }
        
        # Count vulnerabilities
        for result in binary_results + list(docker_results.values()):
            if "vulnerabilities" in result:
                for vuln in result["vulnerabilities"]:
                    summary["total_vulnerabilities"] += 1
                    severity = vuln.get("severity", "").lower()
                    if severity in ["high", "critical"]:
                        summary["high_severity"] += 1
                    elif severity == "medium":
                        summary["medium_severity"] += 1
                    else:
                        summary["low_severity"] += 1
                        
        # Write summary report
        summary_file = self.reports_dir / "cve_summary_report.json"
        with open(summary_file, 'w') as f:
            json.dump(summary, f, indent=2)
            
        logger.info(f"Summary report written to {summary_file}")
        logger.info(f"Total vulnerabilities found: {summary['total_vulnerabilities']}")
        logger.info(f"High/Critical: {summary['high_severity']}, Medium: {summary['medium_severity']}, Low: {summary['low_severity']}")
        
    def run_full_scan(self, scan_docker: bool = True) -> None:
        """Run a complete vulnerability scan"""
        logger.info("Starting SAGE OS CVE vulnerability scan")
        
        # Scan binaries
        binaries = self.find_binaries()
        binary_results = []
        
        for binary in binaries:
            result = self.scan_binary(binary)
            if result:
                binary_results.append(result)
                
        # Scan Docker images if requested
        docker_results = {}
        if scan_docker:
            docker_results = self.scan_docker_images()
            
        # Generate summary
        self.generate_summary_report(binary_results, docker_results)
        
        logger.info("CVE vulnerability scan completed")

def main():
    parser = argparse.ArgumentParser(description="SAGE OS CVE Vulnerability Scanner")
    parser.add_argument("--project-root", default=".", help="Project root directory")
    parser.add_argument("--no-docker", action="store_true", help="Skip Docker image scanning")
    parser.add_argument("--binary", help="Scan a specific binary file")
    
    args = parser.parse_args()
    
    scanner = CVEScanner(args.project_root)
    
    if args.binary:
        # Scan specific binary
        binary_path = Path(args.binary)
        if binary_path.exists():
            result = scanner.scan_binary(binary_path)
            print(json.dumps(result, indent=2))
        else:
            logger.error(f"Binary file {args.binary} not found")
            sys.exit(1)
    else:
        # Run full scan
        scanner.run_full_scan(scan_docker=not args.no_docker)

if __name__ == "__main__":
    main()