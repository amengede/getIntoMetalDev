//
//  objMesh.swift
//  metal5
//
//  Created by Andrew Mengede on 6/1/22.
//
import Foundation

class ObjMesh {
    
    var buffer: [Vertex] = []
    var vertices: [simd_float3] = []
    var texcoords: [simd_float2] = []
    var normals: [simd_float3] = []
    var cursor: Int
    
    init(filename: String) {
        guard let meshURL = Bundle.main.url(forResource: filename, withExtension: "obj") else {
            fatalError()
        }
        
        do {
            let raw_contents: String = try String.init(contentsOf: meshURL);
            let lines: [String] = raw_contents.components(separatedBy: "\n");
            
            cursor = 0;
            while (cursor < lines.count) {
                let line: String = lines[cursor];
                let components: [String] = line.components(separatedBy: " ")
                
                switch (components[0]) {
                case "v":
                    //add vertex to vertices set
                    read_vertex_data(components: components);
                    break;
                case "vt":
                    //add texture coords to texcoords set
                    read_texcoord_data(components: components);
                    break;
                case "vn":
                    //add normal to normals set
                    read_normal_data(components: components);
                    break;
                case "f":
                    //add face data
                    read_face_data(components: components);
                    break;
                default:
                    break;
                }
                
                cursor += 1;
            }
            
        }
        catch {
            fatalError("Couldn't load \(filename)")
        }
    }
    
    func read_vertex_data(components: [String]) {
        vertices.append(
            simd_float3(
                Float(components[1])!,
                Float(components[2])!,
                Float(components[3])!
            )
        );
    }
    
    func read_texcoord_data(components: [String]) {
        texcoords.append(
            simd_float2(
                Float(components[1])!,
                Float(components[2])!
            )
        );
    }
    
    func read_normal_data(components: [String]) {
        normals.append(
            simd_float3(
                Float(components[1])!,
                Float(components[2])!,
                Float(components[3])!
            )
        );
    }
    
    func read_face_data(components: [String]) {
        let triangle_count: Int = components.count - 3
        var triangle = 0
        
        while triangle < triangle_count {
            //Add corner a
            record_corner(description: components[1])

            //Add corner b
            record_corner(description: components[triangle + 2])
            
            //Add corner c
            record_corner(description: components[triangle + 3])
            
            triangle += 1
        }
    }
    
    func record_corner(description: String) {
        
        let vertex_description: [String] = description.components(separatedBy: "/")
        var vertex: Vertex = Vertex()
        vertex.position = simd_float4(vertices[Int(vertex_description[0])! - 1], 1.0)
        vertex.uv = texcoords[Int(vertex_description[1])! - 1]
        vertex.normal = normals[Int(vertex_description[2])! - 1]
        buffer.append(vertex)

    }
}
