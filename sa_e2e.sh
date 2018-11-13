#!/usr/bin/env bash
# sa-bAbI: An automated software assurance code dataset generator
# 
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
#
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE
# ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS.
# CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER
# EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED
# TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY,
# OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON
# UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO
# FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# Released under a MIT (SEI)-style license, please see license.txt or
# contact permission@sei.cmu.edu for full terms.
#
# [DISTRIBUTION STATEMENT A] This material has been approved for
# public release and unlimited distribution. Please see Copyright
# notice for non-US Government use and distribution.
# 
# Carnegie Mellon (R) and CERT (R) are registered in the U.S. Patent
# and Trademark Office by Carnegie Mellon University.
#
# This Software includes and/or makes use of the following Third-Party
# Software subject to its own license:
# 1. clang (http://llvm.org/docs/DeveloperPolicy.html#license)
#     Copyright 2018 University of Illinois at Urbana-Champaign.
# 2. frama-c (https://frama-c.com/download.html) Copyright 2018
#     frama-c team.
# 3. Docker (https://www.apache.org/licenses/LICENSE-2.0.html)
#     Copyright 2004 Apache Software Foundation.
# 4. cppcheck (http://cppcheck.sourceforge.net/) Copyright 2018
#     cppcheck team.
# 5. Python 3.6 (https://docs.python.org/3/license.html) Copyright
#     2018 Python Software Foundation.
# 
# DM18-0995
# 

if [ "$#" -ne 2 ]; then
    echo "Usage: sa_e2e.sh <working_dir> <num_instances>"
    echo "e.g.: sa_e2e.sh ./data 10"
    exit
fi

working_dir=$(realpath $1)
num_instances=$2
tools="clang_sa frama-c cppcheck"

mkdir -p $working_dir

echo ++Generating $num_instances files in $working_dir/src...
begin=$(date +%s)
./sa_gen_cfiles.sh $working_dir $num_instances
end=$(date +%s)
echo Done generating files, took: $(expr $end - $begin) seconds

echo ++Generating tokens in $working_dir/tokens...
begin=$(date +%s)
./sa_gen_tokens.sh $working_dir
end=$(date +%s)
echo Done, generating tokens took: $(expr $end - $begin) seconds

echo ++Running tools...
begin=$(date +%s)
./sa_run_tools.sh $working_dir $tools
end=$(date +%s)
echo Done running tools, took: $(expr $end - $begin) seconds

echo ++Parsing tool outputs...
begin=$(date +%s)
./sa_parse_tool_outputs.sh $working_dir $tools
end=$(date +%s)
echo Done parsing tool output, took: $(expr $end - $begin) seconds

echo ++Scoring tools...
begin=$(date +%s)
./sa_score_tools.sh $working_dir
end=$(date +%s)
echo Done scoring tools, took: $(expr $end - $begin) seconds
