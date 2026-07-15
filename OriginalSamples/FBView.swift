//
//  FBView.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/29/25.
//


class FBView {
    let label: String
    
    var subviews: [FBView]
    
    init(label: String, subviews: [FBView] = []) {
        self.label = label
        self.subviews = subviews
    }
    
    func addSubview(_ subview: FBView) {
        subviews.append(subview)
    }
}

// Part 1: Given a view object, print out the view hierarchy

func generateTestCase1() {
    // Create views
    let A = FBView(label: "A")
    let B = FBView(label: "B")
    let C = FBView(label: "C")
    let D = FBView(label: "D")
    let E = FBView(label: "E")
    let F = FBView(label: "F")
    let G = FBView(label: "G")
    
    
    // Establish hierarchy
    A.addSubview(B)
    A.addSubview(C)
    A.addSubview(D)

    B.addSubview(E)
    B.addSubview(F)

    D.addSubview(G)
    
    
    // TODO: print out below if given input of A
    //A
    //--B
    //----E
    //----F
    //--C
    //--D
    //----G
}

// Part 2:


// Part 2:
// Render out as a list of each line.

// Part 3:
// Collapse and Expand.
// (Think -- user clicks on the element corresponding to the line)

