#!/bin/bash
# test between two hosts 

source ./sg_env.sh
. ${SG_SCRIPTS_HOME}/sg_functions.sh

operate_uuid=`cat /proc/sys/kernel/random/uuid`
primary_role="primary"
secondary_role="secondary"

cd ${SG_SCRIPTS_HOME}

case $1 in
    'start')
        sg_print "start sg process"
        ssh ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh start < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh start </dev/null > /dev/null 2>&1"
        res2=$?
        ;;
    'stop')
        sg_print "stop sg process"
        ssh ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh stop < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh stop < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;
    'clean')
        sg_print "clean test records"
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh stop; sleep 3; ./sg_services.sh clean ${PRIMARY_VOLUME}"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./sg_services.sh stop; sleep 3; ./sg_services.sh clean ${SECONDARY_VOLUME}"
        res2=$?
        ;;

    'enable')
        sg_print "enable volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh enable ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh enable ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'disable')
        sg_print "disable volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh disable ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh disable ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'initialize')
        sg_print "initialize volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh initialize ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh initialize ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'terminate')
        sg_print "terminate volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh terminate ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh terminate ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'attach')
        sg_print "attach volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh attach ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh attach ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'detach')
        sg_print "detach volume "
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./volume.sh detach ${PRIMARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./volume.sh detach ${SECONDARY_VOLUME} < /dev/null > /dev/null 2>&1"
        res2=$?
        ;;

    'create_rep')
        sg_print "create_rep"
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh create_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME} ${SECONDARY_VOLUME}"
        res1=$?
        # reverse PRIMARY_VOLUME and SECONDARY_VOLUME for remote site
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh create_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME} ${PRIMARY_VOLUME} "
        res2=$?
        ;;
    'enable_rep')
        sg_print "enable replication"
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh enable_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME}"
        res1=$?
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh enable_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME}"
        res2=$?
        ;;
    'disable_rep')
        sg_print "disable replication"
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh disable_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME}"
        res1=$?
        sg_print ""
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh disable_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME}"
        res2=$?
        ;;
    'failover_rep')
        sg_print "failover replication remote"
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh failover_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME}"
        res1=$?
        sg_print "failover replication local"
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh failover_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME}"
        res2=$?
        ;;
    'delete_rep')
        sg_print "delete replication"
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh delete_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME}"
        res1=$?
        sg_print ""
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh delete_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME}"
        res2=$?
        ;;
    'reverse_rep')
        sg_print "reverse replication"
        ssh  ${REMOTE_HOST} "cd ${SG_SCRIPTS_HOME}; ./replicate.sh reverse_rep ${operate_uuid} ${secondary_role} ${SECONDARY_VOLUME}"
        res1=$?
        sg_print ""
        ssh  ${LOCAL_HOST} "cd ${SG_SCRIPTS_HOME};./replicate.sh reverse_rep ${operate_uuid} ${primary_role} ${PRIMARY_VOLUME}"
        res2=$?
        ;;
    *)
        sg_print "$0 $1 not support"
        exit 1
        ;;
esac
    if [[ $res1 -ne 0 || $res2 -ne 0 ]]  ; then
        sg_print "operation $1 failed!"
        sg_print "operation $1 result: $res1 $res2"
        exit 1
    else
        sg_print "operation $1 ok!"
    fi
