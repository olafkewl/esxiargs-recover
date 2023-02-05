#/bin/sh
set -x

mkdir UGLY
mv *.args *.vmsd UGLY

VM_NAME=`basename $PWD`


# If VM was running when attacked there is a tilde file, otherwise not, and you'll need to recreate

echo **Recovering $VM_NAME Definition
if [ -f $VM_NAME.vmx~ ]
then
        mv $VM_NAME.vmx UGLY
        cp $VM_NAME.vmx~ $VM_NAME.vmx
else
        echo **No VMX file to Recover, recreate
fi

echo **Recovering VMDKs
for VMDK in `ls *.vmdk | grep -v 'flat'`
do
        echo +$VMDK
        BASE=`basename $VMDK .vmdk`
        SIZE=`ls -l $BASE-flat.vmdk |cut -f3 -d\t|sed "s/^     //"|cut -d\  -f1`
        vmkfstools -c $SIZE -d thin temp.vmdk
        sed -i "s/temp-flat.vmdk/$BASE-flat.vmdk/" temp.vmdk
        sed -i "/ddb.thinProvisioned/d" temp.vmdk
        mv $VMDK UGLY
        mv temp.vmdk $VMDK
        rm temp-flat.vmdk
done

echo Encrypted and junk files in $PWD/UGLY
