﻿<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="xsl msxsl"
>
  <xsl:param name="help"/>
  <xsl:param name="xml"/>
  <xsl:param name="datacontract"/>
  <xsl:param name="binary"/>
  <xsl:param name="protoRpc"/>
  <xsl:param name="observable"/>
  <xsl:param name="preObservable"/>
  <xsl:param name="partialMethods"/>
  
  
  <xsl:output method="text" indent="no" omit-xml-declaration="yes"/>

  <xsl:variable name="optionXml" select="$xml='true'"/>
  <xsl:variable name="optionDataContract" select="$datacontract='true'"/>
  <xsl:variable name="optionBinary" select="$binary='true'"/>
  <xsl:variable name="optionProtoRpc" select="$protoRpc='true'"/>
  <xsl:variable name="optionObservable" select="$observable='true'"/>
  <xsl:variable name="optionPreObservable" select="$preObservable='true'"/>
  <xsl:variable name="optionPartialMethods" select="$partialMethods='true'"/>

  <xsl:template match="*">
    <xsl:message terminate="yes">
      Node not handled: <xsl:for-each select="ancestor-or-self::*">/<xsl:value-of select="name()"/></xsl:for-each>
      <xsl:for-each select="*">
        ; <xsl:value-of select="concat(name(),'=',.)"/>
      </xsl:for-each>
    </xsl:message>
  </xsl:template>
  
  <xsl:template match="FileDescriptorSet">
    <xsl:if test="$help='true'">
      <xsl:message terminate="yes">
        CSharp template for protobuf-net.
        Options:
        General:
          "help" - this page
        Additional serializer support:
          "xml" - enable explicit xml support (XmlSerializer)
          "datacontract" - enable data-contract support (DataContractSerializer; requires .NET 3.0)
          "binary" - enable binary support (BinaryFormatter; not supported on Silverlight)
        Other:
          "protoRpc" - enable proto-rpc client
          "observable" - change notification (observer pattern) support
          "preObservable" - pre-change notification (observer pattern) support (requires .NET 3.5)
          "partialMethods" - provide partial methods for changes (requires C# 3.0)
      </xsl:message>
    </xsl:if>

    <xsl:if test="$optionXml and $optionDataContract">
      <xsl:message terminate="yes">
        Invalid options: xml and data-contract serialization are mutually exclusive.
      </xsl:message>
    </xsl:if>
    // Generated from <xsl:value-of select="name"/>
    <xsl:if test="$optionXml">
      // Option: xml serialization enabled
    </xsl:if>
    <xsl:if test="$optionDataContract">
      // Option: data-contract serialization enabled
    </xsl:if>
    <xsl:if test="$optionBinary">
      // Option: binary serialization enabled
    </xsl:if>
    <xsl:if test="$optionProtoRpc">
      // Option: proto-rpc enabled
    </xsl:if>
    <xsl:if test="$optionObservable">
      // Option: observable (change notifications) enabled
    </xsl:if>
    <xsl:if test="$optionPreObservable">
      // Option: pre-observable (pre-change notifications) enabled
    </xsl:if>
    <xsl:apply-templates select="file/FileDescriptorProto"/>
  </xsl:template>

  <xsl:template match="FileDescriptorProto">
    namespace <xsl:choose>
      <xsl:when test="package"><xsl:value-of select="package"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
    </xsl:choose>
    {
      <xsl:apply-templates select="message_type | enum_type | service"/>
    }
  </xsl:template>
  
  <xsl:template match="DescriptorProto">
    [System.Serializable, ProtoBuf.ProtoContract(Name=@"<xsl:value-of select="name"/>")]
    <xsl:if test="$optionDataContract">
    [System.Runtime.Serialization.DataContract(Name=@"<xsl:value-of select="name"/>")]
    </xsl:if>
    <xsl:if test="$optionXml">
    [System.Xml.Serialization.XmlType(TypeName=@"<xsl:value-of select="name"/>")]
    </xsl:if>
    public partial class <xsl:value-of select="name"/> : ProtoBuf.IExtensible
    <xsl:if test="$optionBinary">, System.Runtime.Serialization.ISerializable</xsl:if>
    <xsl:if test="$optionObservable">, System.ComponentModel.INotifyPropertyChanged</xsl:if>
    <xsl:if test="$optionPreObservable">, System.ComponentModel.INotifyPropertyChanging</xsl:if>
    {
      public <xsl:value-of select="name"/>() {}
      
      <xsl:apply-templates select="*"/>

      <xsl:if test="$optionBinary">
      protected <xsl:value-of select="name"/>(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
        : this() { ProtoBuf.Serializer.Merge(info, this); }
      void System.Runtime.Serialization.ISerializable.GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
        { ProtoBuf.Serializer.Serialize(info, this); }
      </xsl:if>
      <xsl:if test="$optionObservable">
      public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;
      protected virtual void OnPropertyChanged(string propertyName)
        { if(PropertyChanged != null) PropertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propertyName)); }
      </xsl:if>
    <xsl:if test="$optionPreObservable">
      public event System.ComponentModel.PropertyChangingEventHandler PropertyChanging;
      protected virtual void OnPropertyChanging(string propertyName)
      { if(PropertyChanging != null) PropertyChanging(this, new System.ComponentModel.PropertyChangingEventArgs(propertyName)); }
    </xsl:if>
      private ProtoBuf.IExtension extensionObject;
      ProtoBuf.IExtension ProtoBuf.IExtensible.GetExtensionObject(bool createIfMissing)
        { return ProtoBuf.Extensible.GetExtensionObject(ref extensionObject, createIfMissing); }
    }
  </xsl:template>

  <xsl:template match="DescriptorProto/name | DescriptorProto/extension_range | DescriptorProto/extension"/>
  
  <xsl:template match="
                FileDescriptorProto/message_type | FileDescriptorProto/enum_type | FileDescriptorProto/service
                | DescriptorProto/field | DescriptorProto/enum_type | DescriptorProto/message_type
                | DescriptorProto/nested_type | EnumDescriptorProto/value | ServiceDescriptorProto/method">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="EnumDescriptorProto">
    public enum <xsl:value-of select="name"/>
    {
      <xsl:apply-templates select="value"/>
    }
  </xsl:template>

  <xsl:template match="EnumValueDescriptorProto">
    <xsl:value-of select="name"/><xsl:text xml:space="preserve"> = </xsl:text><xsl:choose>
      <xsl:when test="number"><xsl:value-of select="number"/></xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose><xsl:if test="position()!=last()">,
    </xsl:if>
  </xsl:template>

  <xsl:template match="FieldDescriptorProto" mode="format">
    <xsl:choose>
      <xsl:when test="type='TYPE_DOUBLE' or type='TYPE_FLOAT'
                or type='FIXED32' or type='FIXED64'
                or type='SFIXED32' or type='SFIXED64'">FixedSize</xsl:when>
      <xsl:when test="type='TYPE_GROUP'">Group</xsl:when>
      <xsl:when test="not(type) or type='TYPE_INT32' or type='TYPE_INT64'
                or type='TYPE_UINT32' or type='TYPE_UINT64'
                or type='TYPE_ENUM'">TwosComplement</xsl:when>
      <xsl:when test="type='TYPE_SINT32' or type='TYPE_SINT64'">ZigZag</xsl:when>
      <xsl:otherwise>Default</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="FieldDescriptorProto" mode="type">
    <xsl:choose>
      <xsl:when test="not(type)">int</xsl:when>
      <xsl:when test="type='TYPE_DOUBLE'">double</xsl:when>
      <xsl:when test="type='TYPE_FLOAT'">float</xsl:when>
      <xsl:when test="type='TYPE_INT64'">long</xsl:when>
      <xsl:when test="type='TYPE_UINT64'">ulong</xsl:when>
      <xsl:when test="type='TYPE_INT32'">int</xsl:when>
      <xsl:when test="type='TYPE_FIXED64'">ulong</xsl:when>
      <xsl:when test="type='TYPE_FIXED32'">uint</xsl:when>
      <xsl:when test="type='TYPE_BOOL'">bool</xsl:when>
      <xsl:when test="type='TYPE_STRING'">string</xsl:when>
      <xsl:when test="type='TYPE_BYTES'">byte[]</xsl:when>
      <xsl:when test="type='TYPE_UINT32'">uint</xsl:when>
      <xsl:when test="type='TYPE_SFIXED32'">int</xsl:when>
      <xsl:when test="type='TYPE_SFIXED64'">long</xsl:when>
      <xsl:when test="type='TYPE_SINT32'">int</xsl:when>
      <xsl:when test="type='TYPE_SINT64'">long</xsl:when>
      <xsl:when test="type='TYPE_GROUP' or type='TYPE_MESSAGE' or type='TYPE_ENUM'"><xsl:value-of select="substring-after(type_name,'.')"/></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          Field type not implemented: <xsl:value-of select="type"/> (<xsl:value-of select="../../name"/>.<xsl:value-of select="name"/>)
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="FieldDescriptorProto[default_value]" mode="defaultValue">
    <xsl:choose>
      <xsl:when test="type='TYPE_STRING'">@"<xsl:value-of select="default_value"/>"</xsl:when>
      <xsl:when test="type='TYPE_ENUM'"><xsl:apply-templates select="." mode="type"/>.<xsl:value-of select="default_value"/></xsl:when>
      <xsl:when test="type='TYPE_BYTES'"> /* 
        <xsl:value-of select="default_value"/>
        */ null </xsl:when>
      <xsl:otherwise>(<xsl:apply-templates select="." mode="type"/>)<xsl:value-of select="default_value"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    We need to find the first enum value given .foo.bar.SomeEnum - but the enum itself
    only knows about SomeEnum; we need to look at all parent DescriptorProto nodes, and
    the FileDescriptorProto for the namespace.
    
    This does an annoying up/down recursion... a bit expensive, but *generally* OK.
    Could perhaps index the last part of the enum name to reduce overhead?
  -->
  <xsl:template name="GetFirstEnumValue">
    <xsl:variable name="hunt" select="type_name"/>
    <xsl:for-each select="//EnumDescriptorProto">
      <xsl:variable name="fullName">
        <xsl:for-each select="ancestor::FileDescriptorProto">.<xsl:value-of select="package"/></xsl:for-each>
        <xsl:for-each select="ancestor::DescriptorProto">.<xsl:value-of select="name"/></xsl:for-each>
        <xsl:value-of select="concat('.',name)"/>
      </xsl:variable>
      <xsl:if test="$fullName=$hunt"><xsl:value-of select="(value/EnumValueDescriptorProto)[1]/name"/></xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="FieldDescriptorProto[not(default_value)]" mode="defaultValue">
    <xsl:choose>
      <xsl:when test="type='TYPE_STRING'">""</xsl:when>
      <xsl:when test="type='TYPE_MESSAGE'">null</xsl:when>
      <xsl:when test="type='TYPE_BYTES'">null</xsl:when>
      <xsl:when test="type='TYPE_ENUM'"><xsl:apply-templates select="." mode="type"/>.<xsl:call-template name="GetFirstEnumValue"/></xsl:when>
      <xsl:otherwise>default(<xsl:apply-templates select="." mode="type"/>)</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="FieldDescriptorProto[label='LABEL_OPTIONAL' or not(label)]">
    <xsl:variable name="type"><xsl:apply-templates select="." mode="type"/></xsl:variable>
    <xsl:variable name="format"><xsl:apply-templates select="." mode="format"/></xsl:variable>
    <xsl:variable name="defaultValue"><xsl:apply-templates select="." mode="defaultValue"/></xsl:variable>
    private <xsl:value-of select="concat($type, ' _', generate-id())"/> = <xsl:value-of select="$defaultValue"/>;

    [ProtoBuf.ProtoMember(<xsl:value-of select="number"/>, IsRequired = false, Name=@"<xsl:value-of select="name"/>", DataFormat = ProtoBuf.DataFormat.<xsl:value-of select="$format"/>)]
    [System.ComponentModel.DefaultValue(<xsl:value-of select="$defaultValue"/>)]
    <xsl:if test="$optionXml">
    [System.Xml.Serialization.XmlElement(@"<xsl:value-of select="name"/>", Order = <xsl:value-of select="number"/>)]
    </xsl:if>
    <xsl:if test="$optionDataContract">
    [System.Runtime.Serialization.DataMember(Name=@"<xsl:value-of select="name"/>", Order = <xsl:value-of select="number"/>, IsRequired = false)]
    </xsl:if>
    <xsl:call-template name="WriteGetSet">
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="name" select="name"/>
      <xsl:with-param name="field" select="concat('_',generate-id())"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="FieldDescriptorProto[label='LABEL_REQUIRED']">
    <xsl:variable name="type"><xsl:apply-templates select="." mode="type"/></xsl:variable>
    <xsl:variable name="format"><xsl:apply-templates select="." mode="format"/></xsl:variable>
    private <xsl:value-of select="concat($type, ' _', generate-id())"/>;

    [ProtoBuf.ProtoMember(<xsl:value-of select="number"/>, IsRequired = true, Name=@"<xsl:value-of select="name"/>", DataFormat = ProtoBuf.DataFormat.<xsl:value-of select="$format"/>)]
    <xsl:if test="$optionXml">
    [System.Xml.Serialization.XmlElement(@"<xsl:value-of select="name"/>", Order = <xsl:value-of select="number"/>)]
    </xsl:if>
    <xsl:if test="$optionDataContract">
    [System.Runtime.Serialization.DataMember(Name=@"<xsl:value-of select="name"/>", Order = <xsl:value-of select="number"/>, IsRequired = true)]
    </xsl:if>
    <xsl:call-template name="WriteGetSet">
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="name" select="name"/>
      <xsl:with-param name="field" select="concat('_',generate-id())"/>
    </xsl:call-template>    
  </xsl:template>

  <xsl:template name="WriteGetSet">
    <xsl:param name="type"/>
    <xsl:param name="name"/>
    <xsl:param name="field"/>
    public <xsl:value-of select="concat($type,' ',$name)"/>
    {
      get { return <xsl:value-of select="$field"/>; }
      set { <xsl:if test="$optionPartialMethods">On<xsl:value-of select="$name"/>Changing(value); </xsl:if><xsl:if test="$optionPreObservable">OnPropertyChanging(@"<xsl:value-of select="$name"/>"); </xsl:if><xsl:value-of select="$field"/> = value; <xsl:if test="$optionObservable">OnPropertyChanged(@"<xsl:value-of select="$name"/>"); </xsl:if><xsl:if test="$optionPartialMethods">On<xsl:value-of select="$name"/>Changed();</xsl:if>}
    }
    <xsl:if test="$optionPartialMethods">
    partial void On<xsl:value-of select="$name"/>Changing(<xsl:value-of select="$type"/> value);
    partial void On<xsl:value-of select="$name"/>Changed();
    </xsl:if>
  </xsl:template>
  <xsl:template match="FieldDescriptorProto[label='LABEL_REPEATED']">
    <xsl:variable name="type"><xsl:apply-templates select="." mode="type"/></xsl:variable>
    <xsl:variable name="format"><xsl:apply-templates select="." mode="format"/></xsl:variable>
    private readonly System.Collections.Generic.List&lt;<xsl:value-of select="$type" />&gt; _<xsl:value-of select="generate-id()"/> = new System.Collections.Generic.List&lt;<xsl:value-of select="$type"/>&gt;();

    [ProtoBuf.ProtoMember(<xsl:value-of select="number"/>, Name=@"<xsl:value-of select="name"/>", DataFormat = ProtoBuf.DataFormat.<xsl:value-of select="$format"/>)]
    <xsl:if test="$optionXml">
    [System.Xml.Serialization.XmlElement(@"<xsl:value-of select="name"/>", Order = <xsl:value-of select="number"/>)]
    </xsl:if>
    public System.Collections.Generic.List&lt;<xsl:value-of select="$type" />&gt; <xsl:value-of select="name"/>
    {
      get { return _<xsl:value-of select="generate-id()"/>; }
      <xsl:if test="$optionXml">
      set
      { // setter needed for XmlSerializer
        _<xsl:value-of select="generate-id()"/>.Clear();
        if(value != null)
        {
          _<xsl:value-of select="generate-id()"/>.AddRange(value);
        }
      }
      </xsl:if>
    }
  </xsl:template>

  <xsl:template match="ServiceDescriptorProto">
    <xsl:if test="$optionDataContract">
    [System.ServiceModel.ServiceContract(Name = @"<xsl:value-of select="name"/>")]
    </xsl:if>
    public interface I<xsl:value-of select="name"/>
    {
      <xsl:apply-templates select="method"/>
    }
    
    <xsl:if test="$optionProtoRpc">
    public class <xsl:value-of select="name"/>Client : ProtoBuf.ServiceModel.RpcClient
    {
      public <xsl:value-of select="name"/>Client() : base(typeof(I<xsl:value-of select="name"/>)) { }

      <xsl:apply-templates select="method/MethodDescriptorProto" mode="protoRpc"/>
    }
    </xsl:if>
  </xsl:template>

  <xsl:template match="MethodDescriptorProto">
    <xsl:if test="$optionDataContract">
      [System.ServiceModel.OperationContract(Name = @"<xsl:value-of select="name"/>")]
    </xsl:if>
      <xsl:apply-templates select="output_type"/><xsl:text xml:space="preserve"> </xsl:text><xsl:value-of select="name"/>(<xsl:apply-templates select="input_type"/> request);
  </xsl:template>

  <xsl:template match="MethodDescriptorProto" mode="protoRpc">
      <xsl:apply-templates select="output_type"/><xsl:text xml:space="preserve"> </xsl:text><xsl:value-of select="name"/>(<xsl:apply-templates select="input_type"/> request)
      {
        return (<xsl:apply-templates select="output_type"/>) Send(@"<xsl:value-of select="name"/>", request);
      }
  </xsl:template>

  <xsl:template match="MethodDescriptorProto/input_type | MethodDescriptorProto/output_type">
    <xsl:value-of select="substring-after(.,'.')"/>
  </xsl:template>
</xsl:stylesheet>
